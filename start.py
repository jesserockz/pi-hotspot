#!/usr/bin/python

import subprocess
from BaseHTTPServer import BaseHTTPRequestHandler, HTTPServer
import time
import cgi
from html import *

IP = '0.0.0.0'
PORT = 80

def getAccessPoints():
    proc = subprocess.Popen(["/opt/pi-hotspot/scan.sh"], stdout=subprocess.PIPE, shell=True)
    (out, err) = proc.communicate()
    list = [s.strip() for s in out.splitlines()]

    access_points = []
    last_item = ['',False]
    for item in list:
        if item.startswith('*'):
            last_item[1] = True
        else:
            if last_item[0] != '':        
                access_points.append(last_item)
                last_item = [item, False]
            else:
                last_item[0] = item
    access_points.append(last_item)
    return access_points

def setWifi(ssid, passw):
    subprocess.call("/usr/bin/wpa_passphrase {0} {1} >> /etc/wpa_supplicant/wpa_supplicant.conf".format(ssid, passw), shell=True)
    subprocess.call('/sbin/reboot')
        
class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        self.send_response(200)
        self.send_header('Content-type', 'text/html')
        self.end_headers()
        self.wfile.write(header)
        out = GET_body
        for ap in getAccessPoints():
            out += GET_option.format(ap[0], ap[0])
        out += GET_footer
        self.wfile.write(out)

    def do_POST(self):

        form = cgi.FieldStorage(
            fp=self.rfile, 
            headers=self.headers,
            environ={'REQUEST_METHOD':'POST',
                     'CONTENT_TYPE':self.headers['Content-Type'],
                     })
        ssid = ''
        passw = ''
        for field in form.keys():
            if field == 'ssid':
                ssid = form[field].value
            elif field == 'password':
                passw = form[field].value

        self.send_response(200)
        self.send_header('Content-type', 'text/html')
        self.end_headers()
        self.wfile.write(header)
        self.wfile.write(POST_body.format(ssid))
        setWifi(ssid, passw)


if __name__ == '__main__':
    httpd = HTTPServer((IP, PORT), Handler)
    print time.asctime(), "Server started - %s:%s" % (IP, PORT)
    try:
        httpd.serve_forever()
    except KeyboardInterrupt:
        pass
    httpd.server_close()
    print time.asctime(), "Server stopped"
