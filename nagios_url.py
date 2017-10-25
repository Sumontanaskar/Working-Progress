import requests
import sys
import socket
import ssl
from datetime import datetime, timedelta

buffer_days = 430

def ssl_expiry_datetime(hostname, port):
    print hostname, port
    ssl_date_fmt = r'%b %d %H:%M:%S %Y %Z'
    context = ssl.create_default_context()
    conn = context.wrap_socket(
        socket.socket(socket.AF_INET),
        server_hostname=hostname,
    )
    # 3 second timeout because Lambda has runtime limitations
    conn.settimeout(3.0)
    conn.connect((hostname, port))
    ssl_info = conn.getpeercert()
    # parse the string from the certificate into a Python datetime object
    expires = datetime.strptime(ssl_info['notAfter'], ssl_date_fmt)
    remaining = expires - datetime.utcnow()
    if remaining < timedelta(days=0):
        # cert has already expired - uhoh!
        raise AlreadyExpired("Cert expired %s days ago" % remaining.days)
        sys.exit(2)
    elif remaining < timedelta(days=buffer_days):
        # expires sooner than the buffer
        print hostname, 'CA valid for', remaining.days, 'days'
        sys.exit(1)
    else:
        # everything is fine
        print hostname, remaining.days
        sys.exit(0)
def getHostname(url):
    from urlparse import urlparse
    o = urlparse(url)
    url = o.hostname
    port = o.port
    if o.port==None:
        port = '443'
    return url, port

for url in sys.argv[1:]:
    url = str(url)
    hostname, port = getHostname(url)
    remaining = ssl_expiry_datetime(str(hostname), int(port))

#python url_check.py https://trk.mwstats.net/status
