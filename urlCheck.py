import requests

import sys

import socket

import ssl

from datetime import datetime, timedelta



buffer_days = 430



def check_ssl(url):

    print "SSL check"

    try:

        req = requests.get(url, verify=True)

        print url + ' has a valid SSL certificate!'

    except requests.exceptions.SSLError as e:

        print url + ' has INVALID SSL certificate!'+e

    except:

        print 'Connection Error'



def checkResponseTime(url):

    print 'Response time check'

    try:

        time = requests.get(url, verify=True).elapsed.total_seconds()

        print str(time) + ' Elapsed time'

    except requests.exceptions.RequestException as e:

        print 'Error:', e

        pass



def ssl_expiry_datetime(hostname):

    ssl_date_fmt = r'%b %d %H:%M:%S %Y %Z'

    context = ssl.create_default_context()

    conn = context.wrap_socket(

        socket.socket(socket.AF_INET),

        server_hostname=hostname,

    )

    # 3 second timeout because Lambda has runtime limitations

       conn.settimeout(3.0)

    conn.connect((hostname, 443))

    ssl_info = conn.getpeercert()

    # parse the string from the certificate into a Python datetime object

    expires = datetime.strptime(ssl_info['notAfter'], ssl_date_fmt)

    remaining = expires - datetime.utcnow()

    print remaining

    if remaining < timedelta(days=0):

        # cert has already expired - uhoh!

        print remaining.days

        raise AlreadyExpired("Cert expired %s days ago" % remaining.days)

    elif remaining < timedelta(days=buffer_days):

        # expires sooner than the buffer

        print 'Website', hostname, 'Certificate valid for', remaining.days, 'days'

        datasend(hostname, remaining.days)

        return True

    else:

        # everything is fine

        print remaining.days

        return False

def datasend(hostname, days):

    import smtplib



    sender = 'root@localhost.com'

    receivers = ['newsumonts@gmail.com']



    message = """Subject: Website SSL verification



    Website %s Certificate valid for""" % hostname + str(days)



    try:

        smtpObj = smtplib.SMTP('localhost', 25)

        smtpObj.sendmail(sender, receivers, message)

        print "Successfully sent email"

    except:

        print "Error: unable to send email"



def getHostname(url):

    from urlparse import urlparse

    o = urlparse(url)

    url = o.hostname

    return url



for url in sys.argv[1:]:

    print url

    url = str(url)

    check_ssl(url)

    checkResponseTime(url)

    hostname = str(getHostname(url))

    remaining = ssl_expiry_datetime(hostname)

    print remaining

 
