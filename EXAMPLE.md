# 1. Encrypt card

## 1.1. browser ---encrypt_card---> pci

    GET /pci/encrypt_card?callback=jQuery191026070669073427777_1365589442937&cardnumber=5212345678901234&cardexpirymonth=06&cardexpiryyear=2016&cardholdername=Test+Person&cardissuenumber=&cardstartmonth=&cardstartyear=&cardcvc=737&_=1365589442938 HTTP/1.1

## 1.2. browser <---encrypt_card--- pci

    HTTP/1.1 200 OK
    jQuery191026070669073427777_1365589442937({
        "cvckey" : "1eaf5bf64846c0b0bd71fe5339b018ae9179047c4b436b3214bdc282aaf7bc0a4b43411ee4616c00708d22903c0f2543f0e43949e7ec1678bc91ec44c95748cce300be36979c42d9ae42a9ab49c5f80de036c96efcc02456f53efd71a9dbf3cb9c67dedf81f2b2a5ea7498ff03dadff797320b89c9c82c7d8b08901d987685d28ead4bcfaccaf1d09b348819950b6f106e27f492c7190d46461fa08029bcc05762a7006798d1758fc297760ee0a8a2b2f8d2572c860ec3938b111990c9c5dd0d1f93ae23e99b78eaa4b97bc3eda385bdb29528d23859667669a6031c7a370663141c82de4e6d496db704af8245ebf845a48c9312fff5ae6b42680ee238332ef0",
        "cardlast4" : "1234",
        "cardbin" : "521234",
        "cardkey" : "0bf239e27d5eb2d038aa3cd00e7ea66c099d7ea1c70573f56870d155bb64f627ee68bcb0928238541720693d8621621a0b93cd982e5a165f27e7a584a31f599e70312175e2e2d9a0698195d3616b59ee52f72c0e7831e9525726860e8ebbf98bca660fc1310cef8b156bddde6ecae2ed370e9ebbf218c782116ee1c052e2e957f5b05e8f08d57d8273fe08e440be97112d50de5d12e3eec6eac5fb191ca6036254e061aeb20836d89c9cbedc044f5447fbf01bd0ef8bfee8b64cf7ddb5471c2733f8bd4b1b9ce2e313b45061f639635abfd8fe06fb862af1a384ba592b4d6c90cfb5cbdea1ecf94fcdcc74f4a3d09d85bf1ea2d85a778bfa5c191fda89e0a09d",
        "cardnumberreference" : "f859e195-0ca2-4405-b044-93d3be6d3b1a"
    });

# 2. Authorise

## 2.1. browser ---authorise---> nonpci

    POST /nonpci/ HTTP/1.1
    {
        "method": "authorise",
        "params": {
            "cvckey": "1eaf5bf64846c0b0bd71fe5339b018ae9179047c4b436b3214bdc282aaf7bc0a4b43411ee4616c00708d22903c0f2543f0e43949e7ec1678bc91ec44c95748cce300be36979c42d9ae42a9ab49c5f80de036c96efcc02456f53efd71a9dbf3cb9c67dedf81f2b2a5ea7498ff03dadff797320b89c9c82c7d8b08901d987685d28ead4bcfaccaf1d09b348819950b6f106e27f492c7190d46461fa08029bcc05762a7006798d1758fc297760ee0a8a2b2f8d2572c860ec3938b111990c9c5dd0d1f93ae23e99b78eaa4b97bc3eda385bdb29528d23859667669a6031c7a370663141c82de4e6d496db704af8245ebf845a48c9312fff5ae6b42680ee238332ef0",
            "cardlast4": "1234",
            "cardbin": "521234",
            "cardkey": "0bf239e27d5eb2d038aa3cd00e7ea66c099d7ea1c70573f56870d155bb64f627ee68bcb0928238541720693d8621621a0b93cd982e5a165f27e7a584a31f599e70312175e2e2d9a0698195d3616b59ee52f72c0e7831e9525726860e8ebbf98bca660fc1310cef8b156bddde6ecae2ed370e9ebbf218c782116ee1c052e2e957f5b05e8f08d57d8273fe08e440be97112d50de5d12e3eec6eac5fb191ca6036254e061aeb20836d89c9cbedc044f5447fbf01bd0ef8bfee8b64cf7ddb5471c2733f8bd4b1b9ce2e313b45061f639635abfd8fe06fb862af1a384ba592b4d6c90cfb5cbdea1ecf94fcdcc74f4a3d09d85bf1ea2d85a778bfa5c191fda89e0a09d",
            "cardnumberreference": "f859e195-0ca2-4405-b044-93d3be6d3b1a",
            "paymentamount": "100",
            "currencycode": "EUR",
            "orderid": "your_id_for_this_order_if_you_have_one"
        },
        "version": "1.1"
    }

### 2.1.1. nonpci ---authorise_payment_request---> pci

    POST /pci HTTP/1.1
    {
        "params": {
            "browserinfoacceptheader": "application/json, text/javascript, */*; q=0.01",
            "cvckey": "1eaf5bf64846c0b0bd71fe5339b018ae9179047c4b436b3214bdc282aaf7bc0a4b43411ee4616c00708d22903c0f2543f0e43949e7ec1678bc91ec44c95748cce300be36979c42d9ae42a9ab49c5f80de036c96efcc02456f53efd71a9dbf3cb9c67dedf81f2b2a5ea7498ff03dadff797320b89c9c82c7d8b08901d987685d28ead4bcfaccaf1d09b348819950b6f106e27f492c7190d46461fa08029bcc05762a7006798d1758fc297760ee0a8a2b2f8d2572c860ec3938b111990c9c5dd0d1f93ae23e99b78eaa4b97bc3eda385bdb29528d23859667669a6031c7a370663141c82de4e6d496db704af8245ebf845a48c9312fff5ae6b42680ee238332ef0",
            "cardkey": "0bf239e27d5eb2d038aa3cd00e7ea66c099d7ea1c70573f56870d155bb64f627ee68bcb0928238541720693d8621621a0b93cd982e5a165f27e7a584a31f599e70312175e2e2d9a0698195d3616b59ee52f72c0e7831e9525726860e8ebbf98bca660fc1310cef8b156bddde6ecae2ed370e9ebbf218c782116ee1c052e2e957f5b05e8f08d57d8273fe08e440be97112d50de5d12e3eec6eac5fb191ca6036254e061aeb20836d89c9cbedc044f5447fbf01bd0ef8bfee8b64cf7ddb5471c2733f8bd4b1b9ce2e313b45061f639635abfd8fe06fb862af1a384ba592b4d6c90cfb5cbdea1ecf94fcdcc74f4a3d09d85bf1ea2d85a778bfa5c191fda89e0a09d",
            "merchantaccount": "your_psp_merchant_account",
            "shopperip": "192.168.35.1",
            "shopperemail": "joe@joe.com",
            "password": "your_merchant_account_password",
            "shopperreference": "your_shopper_reference",
            "reference": "your_unique_reference",
            "url": "https://pal-test.adyen.com/pal/servlet/soap/Payment",
            "psp": "Adyen",
            "paymentamount": "100",
            "fraudoffset": null,
            "username": "your_psp_username",
            "browserinfouseragent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.8; rv:19.0) Gecko/20100101 Firefox/19.0",
            "selectedbrand": null,
            "currencycode": "EUR"
        },
        "version": "1.1",
        "id": 1,
        "method": "authorise_payment_request"
    }

#### 2.1.1.1. pci ---> psp

    The authorise payment request is made using the decrypted card data,
    the communication protocol varies for each PSP.
    For Adyen, the request is a SOAP HTTPS request.

#### 2.1.1.2. pci <--- psp

    The authorise payment response is received from the PSP.

### 2.1.2. nonpci <---authorise_payment_request--- pci

    The authorise payment response is received from the pci-blackbox,
    stored locally in the nonpci database and assigned a UUID.
    The UUID is returned to the browser as a ticket for the payment.

    HTTP/1.1 200 OK
    {
       "version" : "1.1",
       "error" : null,
       "id" : 1,
       "result" : {
          "md" : "RXdY6/jocNz4DwEuFBaXjrnDk1pITVCu+KC0E2KMTeadrk9pBU4B3NXhaaRFjh3sUi5djeozCc70H2e4CRpSRSST7H6gaaG60oPBAwBDwjdbY3W1zt9BXZouz+P5oj0YXeFywAIEwYZQriWuzsR8dGIsgxBwGR1/50GI01BPu6K8qlAZSybTBXKBkCjNWOKXC3G7OAz/2IyX9YfMjiU66apQZku9qFeG/S3fFuaBIWY2pwPMWvC51X2kbcLo0c1gStFhejGV+uzE3Z5v50adyMfTNeOCaRvmejaLgLkHC0UPe+iibYrdwx9cR/fd6i4pULakMOwcqUxIIdWnlxmcaD+VoK+PbnAqrWAZ2fML9B8=",
          "authcode" : null,
          "fraudresult" : null,
          "parequest" : "eNpVUdtuwjAM/RXEB9RJ7yATqaOTxkOBbeVhj1WwoBJtIU3H5euXtDC2vOSc49ixjzHfK6L0k2SnSGBGbVvsaFRuZ+NpHHAvDIJ4EodB5IdsLHCdfNBJ4DeptmxqwR3muAgPatKV3Be1FljI08tiKbjr+UGIcKdYkVqkIqdWr6sqkaeuVKQQBhnroiKRq67Vh+t8lSH0Asqmq7W6isiPER4EO3UQe62PU4Dz+ezoIc2RTQVUA4KNIzw7WncWtabepdyKVbq5ZLcvvsx3wSo19+3dzZL+zBDsC9wWmoTLuMd8zkacTT0+ZQFCr2NR2UbE6+ZjZFxgZsRBwKP9JxkIt4G/AhqbFdXyKiaRHebBkC7Hpibzwtj5ixGeTc/frKlSG59k4A6+RvGEWWT97SO2TGnM4SEL+zqWINhcuK8O7is26N/qfwBl7qri",
          "refusalreason" : null,
          "issuerurl" : "https://test.adyen.com/hpp/3d/validate.shtml",
          "resultcode" : "RedirectShopper",
          "pspreference" : "8513655898657460"
       }
    }

## 2.2. browser <---authorise--- nonpci

    HTTP/1.1 200 OK
    {
       "version" : "1.1",
       "error" : null,
       "result" : {
          "md" : "d7TGoKacIJmhT4HwJm7Se1cuyVfpW7kux+ymgh8tW6SNJtgCr0n34yYERW8nLB//cWvT+kdVOmU452bF2H2/YqDEq3mXSl1DLu/Ubc0HaW54MYvh7EiLeQMILCO42yv0XMUy8HC0E86Y1oVtHrIJ9O+SnNKjgHl1Ip9ks6Z9kivWuTpgdoBhapYjF8crA9JdcuUGzRQHuDR7C9ZHr9M2K9RElloG3rfgRNf7xiWXD1t6bnzg70hDlti1ZJYIOz71NjWPcpMlKfEECGaOsUgmpuBz3qiv4zVYk4TzvacziFEdXnYkvcwQhjE94taUUmJ9Qni2N00HDpmgbnoN/a6Sqj+VoK+PbnAqrWAZ2fML9B8=",
          "issuerurl" : "https://test.adyen.com/hpp/3d/validate.shtml",
          "authoriserequestid" : "5a6d2b8f-9ed7-47ad-b3b5-248b134411bc",
          "resultcode" : "RedirectShopper",
          "parequest" : "eNpVkd1uwjAMhV8F8QB10n+QidQB0rigoA0udlkFa3SiLaTpCn36JbSMLVc+x7HjfMbdUREt3kk2igSuqa6zTxrlh9l4GgfcC4OQeRFjEY+jscBt8kYXgd+k6rwqBXeY4yI8pClX8piVWmAmLy+rVHDX84MQYZBYkFotxI5qvS2KRF6aXJFC6G0ss4LETjW1Pt3mmzXC3UBZNaVWNxH5McJDYKNO4qj1eQrQtq2j+zJHVgVQCQg2j/CcaNvYqDb9rvlBbBb767r74OlX0qVd0qbd0k/bxJ4Zgr2Bh0yTcBn3mM/ZiPtTl099hnD3MSvsIGK5fxsZCsYeDDzbd5JecJv4a6DBrKiUNzGJ7GceCul6rkoyNwzO3xjhOfT81UKV2nCSgdtzjeIJs5Hle8/YNrmBw0MW3vtYgWBrYVgdDCs20b/V/wAKOKuW",
          "termurl" : "https://pciblackbox.com/3d/5a6d2b8f-9ed7-47ad-b3b5-248b134411bc"
       }
    }

# 3. Authorise, 3-D Secure

    Only relevant for 3-D Secure enabled cards, where resultcode in authorised is RedirectShopper.

## 3.1. browser ---PaReq---> issuer

    POST /hpp/3d/validate.shtml HTTP/1.1
    MD=d7TGoKacIJmhT4HwJm7Se1cuyVfpW7kux+ymgh8tW6SNJtgCr0n34yYERW8nLB//cWvT+kdVOmU452bF2H2/YqDEq3mXSl1DLu/Ubc0HaW54MYvh7EiLeQMILCO42yv0XMUy8HC0E86Y1oVtHrIJ9O+SnNKjgHl1Ip9ks6Z9kivWuTpgdoBhapYjF8crA9JdcuUGzRQHuDR7C9ZHr9M2K9RElloG3rfgRNf7xiWXD1t6bnzg70hDlti1ZJYIOz71NjWPcpMlKfEECGaOsUgmpuBz3qiv4zVYk4TzvacziFEdXnYkvcwQhjE94taUUmJ9Qni2N00HDpmgbnoN/a6Sqj+VoK+PbnAqrWAZ2fML9B8=
    PaReq=eNpVkd1uwjAMhV8F8QB10n+QidQB0rigoA0udlkFa3SiLaTpCn36JbSMLVc+x7HjfMbdUREt3kk2igSuqa6zTxrlh9l4GgfcC4OQeRFjEY+jscBt8kYXgd+k6rwqBXeY4yI8pClX8piVWmAmLy+rVHDX84MQYZBYkFotxI5qvS2KRF6aXJFC6G0ss4LETjW1Pt3mmzXC3UBZNaVWNxH5McJDYKNO4qj1eQrQtq2j+zJHVgVQCQg2j/CcaNvYqDb9rvlBbBb767r74OlX0qVd0qbd0k/bxJ4Zgr2Bh0yTcBn3mM/ZiPtTl099hnD3MSvsIGK5fxsZCsYeDDzbd5JecJv4a6DBrKiUNzGJ7GceCul6rkoyNwzO3xjhOfT81UKV2nCSgdtzjeIJs5Hle8/YNrmBw0MW3vtYgWBrYVgdDCs20b/V/wAKOKuW
    TermUrl=https://192.168.50.129:30001/nonpci/authorise_3d?redirect=1&authoriserequestid=5a6d2b8f-9ed7-47ad-b3b5-248b134411bc

## 3.2. browser <---prompt credentials--- issuer

    HTTP/1.1 200 OK
    <html>
    .
    <form method="post" action="/hpp/3d/authenticate.shtml">
        <input type="text" name="username" />
        <input type="password" name="password" />
    </form>
    .
    </html>

## 3.3. browser ---submit credentials---> issuer

    POST /hpp/3d/authenticate.shtml HTTP/1.1
    MD=4c+VDk4zU0p75kgA345U9iCVN8gH+qp2qjS29q0KqOO4fH3WK/vxVbRhpY8CwJUIqBlmB1IC6FCTN+0bqkJlDmk90NsGZPH5fjvawL5Wzz+Bmz7/IqKwUb2i5xGspX/Pc6KO4SeJ+leOw/U43OR5RdxaUSM3Yqq7oco+Ujg+afEfoExiiYIjbWUthLqszQVrMtQU5lnQEG2GDEH6msAh7mhVhBvVj02S54AI5XLak3QWiua3n2uGBcl5zjDEvpxndVA+Mfp12j4dMDZkTNIF8gaoXYU482uMe09kUd+AB17VWUW5vrA/CVYWt8FFUB23aUT7WM20V5KuW6FIWVgGx3HvBpK99fezbDKpvhNGpCw=
    PaReq=eNpVUdtuwjAM/RXEB9RJKaFUJlJHJ40HLmLsgccqWNCNtpCmg+7rl7RctiiRfI4vsY9xc9BEyTupWpPEOVVVuqdetpv0o1DwgRiKsQhCP7S3L3EVr+ks8Zt0lZWF5B7zfIQ7tOlaHdLCSEzV+WW2kNwfBEOBcIOYk54lckOVWeV5rM51pkkjdDQWaU5yo+vKHJvpco7QEqjKujC6kaMgRLgDrPVRHow5RQCXy8UzXZqnyhyoAATnR3h2tKqdVdl612wnl8n2Ov/Z8sXnl79I9s3Svbg9EwQXgbvUkPQZH7CA8x4XEQsjZqdteUxz14h8/Vj3rArMjtgReHL/xB3gzvGXQCuzpkI1cjxyw9wR0vVUFmQj7AcPG+HZ9PTNiaqM1UkN/U7XUThmznL6th5XJrPicMFEW8cBBJcLt9XBbcXW+rf6Xw9sq4g=
    TermUrl=https://192.168.50.129:30001/nonpci/authorise_3d?redirect=1&authoriserequestid=3987ebf1-133e-46db-88e5-f103bab1c5f1
    password=password
    username=user

## 3.4. browser <---PaRes--- issuer

    HTTP/1.1 200 OK
    <html>
    .
    <form method="post" action="https://192.168.50.129:30001/nonpci/authorise_3d?redirect=1&amp;authoriserequestid=3987ebf1-133e-46db-88e5-f103bab1c5f1">
        <input type="hidden" name="MD" value="4c+VDk4zU0p75kgA345U9iCVN8gH+qp2qjS29q0KqOO4fH3WK/vxVbRhpY8CwJUIqBlmB1IC6FCTN+0bqkJlDmk90NsGZPH5fjvawL5Wzz+Bmz7/IqKwUb2i5xGspX/Pc6KO4SeJ+leOw/U43OR5RdxaUSM3Yqq7oco+Ujg+afEfoExiiYIjbWUthLqszQVrMtQU5lnQEG2GDEH6msAh7mhVhBvVj02S54AI5XLak3QWiua3n2uGBcl5zjDEvpxndVA+Mfp12j4dMDZkTNIF8gaoXYU482uMe09kUd+AB17VWUW5vrA/CVYWt8FFUB23aUT7WM20V5KuW6FIWVgGx3HvBpK99fezbDKpvhNGpCw="/>
        <input type="hidden" name="PaRes" value="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"/>
    </form>
    .
    </html>

## 3.5. browser ---authorise_3d---> nonpci

    POST /nonpci/authorise_3d?redirect=1&authoriserequestid=3987ebf1-133e-46db-88e5-f103bab1c5f1 HTTP/1.1
    MD=4c+VDk4zU0p75kgA345U9iCVN8gH+qp2qjS29q0KqOO4fH3WK/vxVbRhpY8CwJUIqBlmB1IC6FCTN+0bqkJlDmk90NsGZPH5fjvawL5Wzz+Bmz7/IqKwUb2i5xGspX/Pc6KO4SeJ+leOw/U43OR5RdxaUSM3Yqq7oco+Ujg+afEfoExiiYIjbWUthLqszQVrMtQU5lnQEG2GDEH6msAh7mhVhBvVj02S54AI5XLak3QWiua3n2uGBcl5zjDEvpxndVA+Mfp12j4dMDZkTNIF8gaoXYU482uMe09kUd+AB17VWUW5vrA/CVYWt8FFUB23aUT7WM20V5KuW6FIWVgGx3HvBpK99fezbDKpvhNGpCw=
    PaRes=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

### 3.5.1. nonpci ---authorise_payment_request_3d---> pci

    POST /pci HTTP/1.1
    {
        "params": {
            "browserinfoacceptheader": "application/json, text/javascript, */*; q=0.01",
            "merchantaccount": "your_psp_merchant_account",
            "shopperip": "192.168.35.1",
            "password": "your_merchant_account_password",
            "reference": "your_unique_reference",
            "url": "https://pal-test.adyen.com/pal/servlet/soap/Payment",
            "psp": "Adyen",
            "username": "your_psp_username",
            "browserinfouseragent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.8; rv:19.0) Gecko/20100101 Firefox/19.0"
        },
        "version": "1.1",
        "id": 1,
        "method": "authorise_payment_request_3d"
    }

#### 3.5.1.1. pci ---> psp

    The 3-D Secure authorise payment request is made using the PaRes,
    the communication protocol varies for each PSP.
    For Adyen, the request is a SOAP HTTPS request.

#### 3.5.1.2. pci <--- psp

    The 3-D Secure authorise payment response is received from the PSP.

### 3.5.2. nonpci <---authorise_payment_request_3d--- pci

    The 3-D Secure authorise payment response is received from the pci-blackbox,
    stored locally in the nonpci database with the same UUID as the authorise request.

    HTTP/1.1 200 OK
    {
       "version" : "1.1",
       "error" : null,
       "id" : 1,
       "result" : {
          "authcode" : "25186",
          "refusalreason" : null,
          "resultcode" : "Authorised",
          "pspreference" : "8513655898657460"
       }
    }

# 3.6. browser <---authorise_3d--- nonpci

    The customer is redirected to the merchant website.

    HTTP/1.1 302 Found
    Location: http://www.merchantsite.com/successurl
