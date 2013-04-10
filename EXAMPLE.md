# 1. Encrypt card

## 1.1. browser ---https---> pci

    GET /pci/encrypt_card?callback=jQuery191026070669073427777_1365589442937&cardnumber=5212345678901234&cardexpirymonth=06&cardexpiryyear=2016&cardholdername=Test+Person&cardissuenumber=&cardstartmonth=&cardstartyear=&cardcvc=737&_=1365589442938 HTTP/1.1

## 1.2. browser <---https--- pci

    HTTP/1.1 200 OK
    jQuery191026070669073427777_1365589442937({
        "cvckey" : "1eaf5bf64846c0b0bd71fe5339b018ae9179047c4b436b3214bdc282aaf7bc0a4b43411ee4616c00708d22903c0f2543f0e43949e7ec1678bc91ec44c95748cce300be36979c42d9ae42a9ab49c5f80de036c96efcc02456f53efd71a9dbf3cb9c67dedf81f2b2a5ea7498ff03dadff797320b89c9c82c7d8b08901d987685d28ead4bcfaccaf1d09b348819950b6f106e27f492c7190d46461fa08029bcc05762a7006798d1758fc297760ee0a8a2b2f8d2572c860ec3938b111990c9c5dd0d1f93ae23e99b78eaa4b97bc3eda385bdb29528d23859667669a6031c7a370663141c82de4e6d496db704af8245ebf845a48c9312fff5ae6b42680ee238332ef0",
        "cardlast4" : "1234",
        "cardbin" : "521234",
        "cardkey" : "0bf239e27d5eb2d038aa3cd00e7ea66c099d7ea1c70573f56870d155bb64f627ee68bcb0928238541720693d8621621a0b93cd982e5a165f27e7a584a31f599e70312175e2e2d9a0698195d3616b59ee52f72c0e7831e9525726860e8ebbf98bca660fc1310cef8b156bddde6ecae2ed370e9ebbf218c782116ee1c052e2e957f5b05e8f08d57d8273fe08e440be97112d50de5d12e3eec6eac5fb191ca6036254e061aeb20836d89c9cbedc044f5447fbf01bd0ef8bfee8b64cf7ddb5471c2733f8bd4b1b9ce2e313b45061f639635abfd8fe06fb862af1a384ba592b4d6c90cfb5cbdea1ecf94fcdcc74f4a3d09d85bf1ea2d85a778bfa5c191fda89e0a09d",
        "cardnumberreference" : "f859e195-0ca2-4405-b044-93d3be6d3b1a"
    });

# 2. Pay using card

## 2.1. browser ---https---> nonpci

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

### 2.1.1. nonpci ---https---> pci

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

### 2.1.2. nonpci <--- pci

    The authorise payment response is received from the pci-blackbox,
    stored locally in the nonpci database and assigned a UUID.
    The UUID is returned to the browser as a ticket for the payment.

    HTTP/1.1 200 OK
    {
       "version" : "1.1",
       "error" : null,
       "id" : 1,
       "result" : {
          "dccamount" : null,
          "md" : "RXdY6/jocNz4DwEuFBaXjrnDk1pITVCu+KC0E2KMTeadrk9pBU4B3NXhaaRFjh3sUi5djeozCc70H2e4CRpSRSST7H6gaaG60oPBAwBDwjdbY3W1zt9BXZouz+P5oj0YXeFywAIEwYZQriWuzsR8dGIsgxBwGR1/50GI01BPu6K8qlAZSybTBXKBkCjNWOKXC3G7OAz/2IyX9YfMjiU66apQZku9qFeG/S3fFuaBIWY2pwPMWvC51X2kbcLo0c1gStFhejGV+uzE3Z5v50adyMfTNeOCaRvmejaLgLkHC0UPe+iibYrdwx9cR/fd6i4pULakMOwcqUxIIdWnlxmcaD+VoK+PbnAqrWAZ2fML9B8=",
          "authcode" : null,
          "dccsignature" : null,
          "fraudresult" : null,
          "parequest" : "eNpVUdtuwjAM/RXEB9RJ7yATqaOTxkOBbeVhj1WwoBJtIU3H5euXtDC2vOSc49ixjzHfK6L0k2SnSGBGbVvsaFRuZ+NpHHAvDIJ4EodB5IdsLHCdfNBJ4DeptmxqwR3muAgPatKV3Be1FljI08tiKbjr+UGIcKdYkVqkIqdWr6sqkaeuVKQQBhnroiKRq67Vh+t8lSH0Asqmq7W6isiPER4EO3UQe62PU4Dz+ezoIc2RTQVUA4KNIzw7WncWtabepdyKVbq5ZLcvvsx3wSo19+3dzZL+zBDsC9wWmoTLuMd8zkacTT0+ZQFCr2NR2UbE6+ZjZFxgZsRBwKP9JxkIt4G/AhqbFdXyKiaRHebBkC7Hpibzwtj5ixGeTc/frKlSG59k4A6+RvGEWWT97SO2TGnM4SEL+zqWINhcuK8O7is26N/qfwBl7qri",
          "refusalreason" : null,
          "issuerurl" : "https://test.adyen.com/hpp/3d/validate.shtml",
          "resultcode" : "RedirectShopper",
          "pspreference" : "8513655898657460"
       }
    }

## 2.2. browser <---https--- nonpci

    HTTP/1.1 200 OK
    {
       "version" : "1.1",
       "error" : null,
       "result" : {
          "md" : "d7TGoKacIJmhT4HwJm7Se1cuyVfpW7kux+ymgh8tW6SNJtgCr0n34yYERW8nLB//cWvT+kdVOmU452bF2H2/YqDEq3mXSl1DLu/Ubc0HaW54MYvh7EiLeQMILCO42yv0XMUy8HC0E86Y1oVtHrIJ9O+SnNKjgHl1Ip9ks6Z9kivWuTpgdoBhapYjF8crA9JdcuUGzRQHuDR7C9ZHr9M2K9RElloG3rfgRNf7xiWXD1t6bnzg70hDlti1ZJYIOz71NjWPcpMlKfEECGaOsUgmpuBz3qiv4zVYk4TzvacziFEdXnYkvcwQhjE94taUUmJ9Qni2N00HDpmgbnoN/a6Sqj+VoK+PbnAqrWAZ2fML9B8=",
          "issuerurl" : "https://test.adyen.com/hpp/3d/validate.shtml",
          "authoriserequestid" : "5a6d2b8f-9ed7-47ad-b3b5-248b134411bc",
          "parequest" : "eNpVkd1uwjAMhV8F8QB10n+QidQB0rigoA0udlkFa3SiLaTpCn36JbSMLVc+x7HjfMbdUREt3kk2igSuqa6zTxrlh9l4GgfcC4OQeRFjEY+jscBt8kYXgd+k6rwqBXeY4yI8pClX8piVWmAmLy+rVHDX84MQYZBYkFotxI5qvS2KRF6aXJFC6G0ss4LETjW1Pt3mmzXC3UBZNaVWNxH5McJDYKNO4qj1eQrQtq2j+zJHVgVQCQg2j/CcaNvYqDb9rvlBbBb767r74OlX0qVd0qbd0k/bxJ4Zgr2Bh0yTcBn3mM/ZiPtTl099hnD3MSvsIGK5fxsZCsYeDDzbd5JecJv4a6DBrKiUNzGJ7GceCul6rkoyNwzO3xjhOfT81UKV2nCSgdtzjeIJs5Hle8/YNrmBw0MW3vtYgWBrYVgdDCs20b/V/wAKOKuW",
          "termurl" : "https://pciblackbox.com/3d/5a6d2b8f-9ed7-47ad-b3b5-248b134411bc"
       }
    }
