import os
import pandas as pd
import numpy as np
from scipy import signal
from shutil import copy, rmtree
pd.options.mode.chained_assignment = None  # unterdrueckt SettingWithCopyWarning (wegen Verkettung)


input_file = "inputAccelero.csv"

src_name = input_file.split("/")[-1][0:-4]
results_directory = 'results'
sub_dst = (results_directory + "/" + src_name)
start_buffer = "0s"
stop_buffer = "0s"
minimum_hours = 6
window_size = 30
fs = 100  # sampling frequency
band_pass_cutoff = (0.25, 12.0,)  # cutoffs for band pass filter
minimum_rest_block = 30
minimum_rest_threshold = 0.0
maximum_rest_threshold = 1000.0
allowed_rest_break = 60
min_t = 25.0  # temperature_threshold


def split_days_geneactiv_csv():
    """Splits the GeneActiv accelerometer data into 24 hour chunks, defined from noon to noon."""
    os.mkdir(sub_dst + "/raw_days")
    # load data and fix time_stamps
    data = pd.read_csv(
        input_file,
        # Column(s) to use as the row labels of the DataFrame, either given as string name or column index.
        index_col=0,
        skiprows=100,
        header=None,
        names=["Time", "X", "Y", "Z", "LUX", "Button", "T", "A", "B", "C", "D", "E"],
        usecols=["Time", "X", "Y", "Z", "LUX", "T"],
        dtype={
            "Time": object,
            "X": np.float64,
            "Y": np.float64,
            "Z": np.float64,
            "LUX": np.int64,
            "Button": bool,
            "T": np.float64,
            "A": np.float64,
            "B": np.float64,
            "C": np.float64,
            "D": np.float64,
            "E": np.float64

        },
        low_memory=False,
    )
    data.index = pd.to_datetime(data.index, format="%Y-%m-%d %H:%M:%S:%f").values
    data = data.loc[
           data.index[0]
           + pd.Timedelta(start_buffer): data.index[-1]
                                             - pd.Timedelta(stop_buffer)
           ]
    # cut to defined start and end times if specified
    start_time = ""
    stop_time = ""
    if start_time and stop_time:
        start_time = pd.to_datetime(
            start_time, format="%Y-%m-%d %H:%M:%S:%f"
        )
        stop_time = pd.to_datetime(
            stop_time, format="%Y-%m-%d %H:%M:%S:%f"
        )
        data = data.loc[start_time: stop_time]
    elif start_time:
        start_time = pd.to_datetime(
            start_time, format="%Y-%m-%d %H:%M:%S:%f"
        )
        data = data.loc[start_time:]
    elif stop_time:
        stop_time = pd.to_datetime(
            stop_time, format="%Y-%m-%d %H:%M:%S:%f"
        )
        data = data.loc[: stop_time]
    days = data.groupby(pd.Grouper(level=0, freq="24h", base=12))
    # iterate through days keeping track of the day
    count = 0
    print('so viele Tage gibt es: ' + str(len(days)))
    for day in days:
        # save each 24 hour day separately if there's enough data to analyze
        df = day[1].copy()
        available_hours = len(df) / 3600.0
        print("available hours: " + str(available_hours))
        print("minimum_hours: " + str(minimum_hours))
        if available_hours >= minimum_hours:
            count += 1
            results_directory = "/raw_days/{}_day_{}.h5".format(
                src_name, str(count).zfill(2)
            )
            df.to_hdf(sub_dst + results_directory, key="raw_geneactiv_data_24hr", mode="w")
    return


def band_pass_filter(
    data_df, sampling_rate, bp_cutoff, order, channels=["X", "Y", "Z"]
):
    """
    Band-pass filter a given sensor signal.

    :param data_df: dataframe housing sensor signals
    :param sampling_rate: sampling rate of signal
    :param bp_cutoff: filter cutoffs
    :param order: filter order
    :param channels: channels of signal to filter
    :return: dataframe of raw and filtered data
    """
    data = data_df[channels].values

    # Calculate the critical frequency (radians/sample) based on cutoff frequency (Hz) and sampling rate (Hz)
    critical_frequency = [
        bp_cutoff[0] * 2.0 / sampling_rate,
        bp_cutoff[1] * 2.0 / sampling_rate,
    ]

    # Get the numerator (b) and denominator (a) of the IIR filter
    [b, a] = signal.butter(
        N=order, Wn=critical_frequency, btype="bandpass", analog=False
    )

    # Apply filter to raw data
    bp_filtered_data = signal.filtfilt(b, a, data, padlen=10, axis=0)

    new_channel_labels = [ax + "_bp_filt_" + str(bp_cutoff) for ax in channels]

    data_df[new_channel_labels] = pd.DataFrame(bp_filtered_data)

    return data_df


class ColeKripke:
    """
    Runs sleep wake detection on epoch level activity data. Epochs are 1 minute long and activity is represented
    by an activity index.
    """

    def __init__(self, activity_index):
        """
        Initialization of the class

        :param activity_index: pandas dataframe of epoch level activity index values
        """
        self.activity_index = activity_index
        self.predictions = None

    def predict(self, sf=np.array(0.193125)):
        """
        Runs the prediction of sleep wake states based on activity index data.

        :param sf: scale factor to use for the predictions (default corresponds to scale factor optimized for use with
        the activity index, if other activity measures are desired the scale factor can be modified or optimized.)
        The recommended range for the scale factor is between 0.1 and 0.25 depending on the sensitivity to activity
        desired, and possibly the population being observed.

        :return: rescored predictions
        """
        kernel = (
            sf
            * np.array([4.64, 6.87, 3.75, 5.07, 16.19, 5.84, 4.024, 0.00, 0.00])[::-1]
        )
        scores = np.convolve(self.activity_index, kernel, "same")
        scores[scores >= 0.5] = 1
        scores[scores < 0.5] = 0

        # rescore the original predictions
        self.rescore(scores)
        return self.predictions

    def rescore(self, predictions):
        """
        Application of Webster's rescoring rules as described in the Cole-Kripke paper.

        :param predictions: array of predictions
        :return: rescored predictions
        """
        rescored = predictions.copy()
        # rules a through c
        wake_bin = 0
        for t in range(len(rescored)):
            if rescored[t] == 1:
                wake_bin += 1
            else:
                if (
                    14 < wake_bin
                ):  # rule c: at least 15 minutes of wake, next 4 minutes of sleep get rescored
                    rescored[t: t + 4] = 1.0
                elif (
                    9 < wake_bin < 15
                ):  # rule b: at least 10 minutes of wake, next 3 minutes of sleep get rescored
                    rescored[t: t + 3] = 1.0
                elif (
                    3 < wake_bin < 10
                ):  # rule a: at least 4 minutes of wake, next 1 minute of sleep gets rescored
                    rescored[t] = 1.0
                wake_bin = 0
        # rule d: 6 minutes or less of sleep surrounded by at least 10 minutes of wake on each side gets rescored
        sleep_bin = 0
        start_ind = 0
        for t in range(10, len(rescored) - 10):
            if rescored[t] == 0:
                sleep_bin += 1
                if sleep_bin == 1:
                    start_ind = t
            else:
                if 0 < sleep_bin <= 6:
                    if (
                        sum(rescored[start_ind - 10: start_ind]) == 10.0
                        and sum(rescored[t: t + 10]) == 10.0
                    ):
                        rescored[start_ind:t] = 1.0
                sleep_bin = 0
        self.predictions = rescored


def activity_index(signal_df, channels=["X", "Y", "Z"]):
    """
    Compute activity index of sensor signals.

    :param signal_df: dataframe housing desired sensor signals
    :param channels: channels of signal to compute activity index
    :return: dataframe housing calculated activity index
    """
    ai_df = pd.DataFrame()
    ai_df["activity_index"] = [np.var(signal_df[channels], axis=0).mean() ** 0.5]
    return ai_df


def extract_activity_index():
    """Calculates the activity index feature on each 24 hour day."""
    os.mkdir(sub_dst + "/activity_index_days")
    count = 0
    # get days
    days = sorted(
        [
            sub_dst + "/raw_days/" + i
            for i in os.listdir(sub_dst + "/raw_days/")
            if ".DS_Store" not in i
        ]
    )
    for day in days:
        count += 1
        # load data
        df = pd.read_hdf(day)
        activity = []
        header = ["Time", "activity_index"]
        idx = 0
        # window = int(window_size * fs)
        # incrementer = int(window_size * fs)
        window = int(window_size)
        incrementer = int(window_size)

        # iterate through windows
        while idx < len(df) - incrementer:
            # preprocessing: BP Filter
            temp = df[["X", "Y", "Z"]].iloc[idx: idx + window]
            start_time = temp.index[0]
            temp.index = range(len(temp.index))  # reset index
            temp = band_pass_filter(
                temp, fs, bp_cutoff=band_pass_cutoff, order=3
            )

            # activity index extraction
            bp_channels = [
                i for i in temp.columns.values[1:] if "bp" in i
            ]  # band pass filtered channels
            activity.append(
                [
                    start_time,
                    activity_index(temp, channels=bp_channels).values[0][0],
                ]
            )
            idx += incrementer

        # save data
        activity = pd.DataFrame(activity)
        activity.columns = header
        activity.set_index("Time", inplace=True)
        results_directory = "/activity_index_days/{}_activity_index_day_{}.h5".format(
            src_name, str(count).zfill(2)
        )
        activity.to_hdf(
            sub_dst + results_directory, key="activity_index_data_24hr", mode="w"
        )


def roll_med(df, num_samples):
    """Calculate the rolling median of a pandas dataframe.
    :param df: pandas dataframe
    :param num_samples: number of samples to include in the window
    :return: pandas dataframe containing the rolling median values."""

    # initialize indexer and rolling median list
    idx = 0
    med = []
    while idx < len(df) - num_samples:
        med.append(
            [df.index[idx], df.iloc[idx: idx + num_samples].median()]
        )  # get start index, std value
        idx += 1
    # format data frame
    df = pd.DataFrame(med, columns=["Time", "Data"])
    df.set_index(df.Time, inplace=True)
    df.drop(inplace=True, columns="Time")
    return df


def major_rest_period():
    """Determines the major rest period"""
    print("in major rest methode")
    os.mkdir(sub_dst + "/major_rest_period")
    count = 0
    mrps = []
    header = ["day", "major_rest_period", "available_hours"]
    # get days
    days = sorted(
        [
            sub_dst + "/raw_days/" + i
            for i in os.listdir(sub_dst + "/raw_days/")
            if ".DS_Store" not in i
        ]
    )
    for day in days:
        df = pd.read_hdf(day)
        df = df[["X", "Y", "Z", "T"]]
        available_hours = len(df) / 3600.0
        # available_hours = (len(df) / float(fs)) / 3600.0
        count += 1

        # process data
        df = df.rolling(int(5 * fs)).median()  # run rolling median 5 second
        df["angle"] = np.arctan(
            df["Z"] / ((df["X"] ** 2 + df["Y"] ** 2) ** 0.5)
        ) * (
            180.0 / np.pi
        )  # get angle

        df = (
            df[["angle", "T"]].resample("5s").mean().fillna(0)
        )  # get 5 second average

        # save intermediate data for plotting
        df["angle"].to_hdf(
            sub_dst
            + "/major_rest_period/5_second_average_arm_angle_day_{}.h5".format(
                str(count).zfill(2)
            ),
            key="arm_angle_data_24hr",
            mode="w",
        )

        df["angle"] = np.abs(
            df["angle"] - df["angle"].shift(1)
        )  # get absolute difference
        df_angle = roll_med(df["angle"], 60)  # run rolling median 5 minute
        df_temp = roll_med(df["T"], 60)  # run rolling median 5 minute

        # calculate and apply threshold
        thresh = np.min(
            [
                np.max(
                    [
                        np.percentile(df_angle.Data.dropna().values, 10) * 15.0,
                        minimum_rest_threshold,
                    ]
                ),
                maximum_rest_threshold,
            ]
        )
        df_angle.Data[df_angle.Data < thresh] = 0  # apply threshold
        df_angle.Data[df_angle.Data >= thresh] = 1  # apply threshold

        # drop rest periods where temperature is below the temp threshold
        df_angle.Data[df_temp.Data <= min_t] = 1
        df = df_angle

        # drop rest blocks < minimum_rest_block minutes (except first and last)
        df["block"] = (df.Data.diff().ne(0)).cumsum()
        groups, iter_count = df.groupby(by="block"), 0
        for group in groups:
            iter_count += 1
            if iter_count == 1 or iter_count == len(groups):
                continue
            if (
                group[1]["Data"].sum() == 0
                and len(group[1]) < 12 * minimum_rest_block
            ):
                df.Data[group[1].index[0]: group[1].index[-1]] = 1

        # drop active blocks < allowed_rest_break minutes (except first and last)
        df["block"] = (df.Data.diff().ne(0)).cumsum()
        groups, iter_count = df.groupby(by="block"), 0
        for group in groups:
            iter_count += 1
            if iter_count == 1 or iter_count == len(groups):
                continue
            if (
                len(group[1]) == group[1]["Data"].sum()
                and len(group[1]) < 12 * allowed_rest_break
            ):
                df.Data[group[1].index[0]: group[1].index[-1]] = 0

        # get longest block
        df["block"] = (df.Data.diff().ne(0)).cumsum()
        best = 0
        mrp = []
        for group in df.groupby(by="block"):
            if group[1]["Data"].sum() == 0 and len(group[1]) > best:
                best = len(group[1])
                mrp = [group[1].index[0], group[1].index[-1] + pd.Timedelta("5m")]

        # save predictions
        df.drop(columns=["block"], inplace=True)
        df.to_hdf(
            sub_dst
            + "/major_rest_period/rest_periods_day_{}.h5".format(
                str(count).zfill(2)
            ),
            key="rest_period_data_24hr",
            mode="w",
        )

        mrps.append([count, mrp, available_hours])

    # aggregate and save the major rest period for each day
    mrps = pd.DataFrame(mrps)
    mrps.columns = header
    mrps.set_index("day", inplace=True)
    results_directory = "/major_rest_period/{}_major_rest_periods.csv".format(src_name)
    mrps.to_csv(sub_dst + results_directory)


def sleep_wake_predict():
    """Run sleep wake prediction based on the activity index feature."""
    os.mkdir(sub_dst + "/sleep_wake_predictions")
    count = 0
    # get days
    days = sorted(
        [
            sub_dst + "/activity_index_days/" + i
            for i in os.listdir(sub_dst + "/activity_index_days/")
            if ".DS_Store" not in i
        ]
    )
    for day in days:
        count += 1
        df = pd.read_hdf(day)
        # run the sleep wake predictions
        ck = ColeKripke(df.activity_index)
        df["sleep_predictions"] = ck.predict()
        # save predictions
        df.drop(inplace=True, columns=["activity_index"])
        # [[]])
        df.to_hdf(
            sub_dst
            + "/sleep_wake_predictions/sleep_wake_day_{}.h5".format(
                str(count).zfill(2)
            ),
            key="sleep_wake_data_24hr",
            mode="w",
        )


def calculate_endpoints():
    """Calculate the metrics and endpoints of interest."""
    os.mkdir(sub_dst + "/sleep_endpoints")  # set up output directory
    count = 0
    # get days
    days = sorted(
        [
            sub_dst + "/sleep_wake_predictions/" + i
            for i in os.listdir(sub_dst + "/sleep_wake_predictions/")
            if ".DS_Store" not in i
        ]
    )

    # get major rest periods for each day
    mrps = pd.read_csv(
        sub_dst
        + "/major_rest_period/{}_major_rest_periods.csv".format(src_name),
        parse_dates=True,
        index_col="day",
    )
    endpoints = []
    for day in days:
        count += 1
        df = pd.read_hdf(day)
        # get and format times
        times = mrps.loc[count].major_rest_period
        try:
            idt = times.index("[T")
            times = times[: idt + 1] + "pd." + times[idt + 1:]
            idt = times.index(", ")
            times = times[: idt + 2] + "pd." + times[idt + 2:]
            times = eval(times)
            df = df.loc[times[0]: times[1]]
        except ValueError:
            pass

        # get total sleep time
        tst = len(df) - sum(df.values)

        # get percent time asleep
        pct_time_sleep = 100.0 * (len(df) - sum(df.values)) / float(len(df))

        # get wake after sleep onset
        waso = df.loc[df.idxmin()[0]:]
        waso = waso.sum()[0]

        # get sleep onset latency
        sleep_onset_lat = (df.idxmin()[0] - df.index[0]).total_seconds() / 60.0

        # number of wake bouts
        num_wake_bouts = 0
        wake_bout_df = df.copy()
        wake_bout_df["block"] = (
            wake_bout_df.sleep_predictions.diff().ne(0)
        ).cumsum()
        for group in wake_bout_df.groupby(by="block"):
            if group[1]["sleep_predictions"].sum() > 0:
                num_wake_bouts += 1
        endpoints.append(
            [
                int(count),
                int(tst[0]),
                int(np.round(pct_time_sleep[0])),
                int(waso),
                int(sleep_onset_lat),
                int(num_wake_bouts),
            ]
        )

    # build and save output dataframe
    hdr = [
        "day",
        "total_sleep_time",
        "percent_time_asleep",
        "waso",
        "sleep_onset_latency",
        "number_wake_bouts",
    ]
    endpoints = pd.DataFrame(endpoints)
    endpoints.columns = hdr
    endpoints.set_index(endpoints.day, inplace=True)
    endpoints.drop(columns="day", inplace=True)
    endpoints.to_csv(sub_dst + "/sleep_endpoints/sleep_endpoints_summary.csv")


def aggregate_results():
    """Aggregates all results in a single folder."""
    os.mkdir(sub_dst + "/results")  # set up output directory
    # collect results files
    srcs = []
    srcs += [
        sub_dst + "/major_rest_period/" + x
        for x in os.listdir(sub_dst + "/major_rest_period")
        if ".csv" in x and ".DS_Store" not in x
    ]
    srcs += [
        sub_dst + "/sleep_endpoints/" + x
        for x in os.listdir(sub_dst + "/sleep_endpoints")
        if ".DS_Store" not in x
    ]

    # aggregate
    for src in srcs:
        copy(src, sub_dst + "/results")


def clear_data():
    """Clears all intermediate data, keeping only results."""
    # collect directories for deletion
    direcs = [
        os.path.join(sub_dst, x)
        for x in os.listdir(sub_dst)
        if "results" not in x and ".DS_Store" not in x
    ]
    # delete
    for direc in direcs:
        rmtree(direc)


def run_sleep_detection():
    print('Sleep Detection gestartet')
    print('mach output dir')
    os.mkdir(sub_dst)  # set up output directory
    # split the data into 24 hour periods
    print("Loading CSV data...")
    split_days_geneactiv_csv()
    print("Extracting activity index...")
    extract_activity_index()
    print("Detecting major rest period...")
    major_rest_period()
    print("Running sleep/wake predictions...")
    sleep_wake_predict()
    print("Calculating endpoints...")
    calculate_endpoints()
    print("Aggregating results...")
    aggregate_results()
