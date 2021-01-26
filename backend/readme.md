Den Server mit Python 3.x laufen lassen und alle Module installieren 
aus requirements.txt

Starten des Servers mit : 
export FLASK_APP=server.py (einmalig pro Session oder dauerhaft exportieren)
flask run

zum starten mit von außen erreichbarer IP:
flask run -h 192.168.X.X