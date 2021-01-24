from io import BytesIO
import pytest
import sys
import os
import sys

root_folder = os.path.abspath(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
sys.path.append(root_folder)
import server


@pytest.fixture(scope='module')
def test_client():
    flask_app = server.app
    testing_client = flask_app.test_client()
    ctx = flask_app.app_context()
    ctx.push()
    yield testing_client
    ctx.pop()


def test_file_upload(test_client):
    data = {
        'field': 'value',
        'file': ('tests/test.csv', 'test.csv')
    }

    rv = test_client.post('/data', buffered=True,
                          content_type='multipart/form-data',
                          data=data)
    assert rv.status_code == 200

def test_wrong_filetype(test_client):
    data = {
        'field': 'value',
        'file': ('tests/test.png', 'test.png')
    }

    rv = test_client.post('/data', buffered=True,
                          content_type='multipart/form-data',
                          data=data)
    assert rv.status_code == 415

def test_no_file(test_client):
    data = {
    }

    rv = test_client.post('/data', buffered=True,
                          content_type='multipart/form-data',
                          data=data)
    assert rv.status_code == 412
def test_file_empty(test_client):
    data = {
        'field': 'value',
        'file': ''
    }

    rv = test_client.post('/data', buffered=True,
                          content_type='multipart/form-data',
                          data=data)
    assert rv.status_code == 412