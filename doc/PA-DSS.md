# PA-DSS Requirements and Security Assessment Procedures

## 1. Do not retain full magnetic stripe, card validation code or value (CAV2, CID, CVC2, CVV2), or PIN block data

### 1.1. Do not store sensitive authentication data after authorization (even if encrypted): Sensitive authentication data includes the data as cited in the following Requirements 1.1.1 through 1.1.3.

#### 1.1.1. After authorization, do not store the full contents of any track from the magnetic stripe (located on the back of a card, contained in a chip, or elsewhere). This data is alternatively called full track, track, track 1, track 2, and magnetic-stripe data.

N/A, the pci-blackbox doesn't deal with physical cards nor any magnetic stripe data.

#### 1.1.2. After authorization, do not store the cardvalidation value or code (three-digit or four-digit number printed on the front or back of a payment card) used to verify card-not-present transactions.

The CVV2/CVC2 is temporarily stored and encrypted in the call to <code>encrypt_card()</code> and is deleted in the same database transaction as the authorization takes place.

Proof from source code, decrypt_cvc.sql, line 11:

    DELETE FROM EncryptedCVCs WHERE CVCKeyHash = _CVCKeyHash RETURNING CVCData INTO STRICT _CVCData;

#### 1.1.3. After authorization, do not store the personal identification number (PIN) or the encrypted PIN block.

N/A, the pci-blackbox doesn't deal with physical cards nor any PINs.

#### 1.1.4. Securely delete any magnetic stripe data, card validation values or codes, and PINs or PIN block data stored by previous versions of the payment application, in accordance with industryaccepted standards for secure deletion, as defined, for example by the list of approved products maintained by the National Security Agency, or by other State or National standards or regulations. Note: This requirement only applies if previous versions of the payment application stored sensitive authentication data

N/A, the pci-blackbox has never permanentely stored any such data in any version.

#### 1.1.5. Securely delete any sensitive authentication data (pre-authorization data) used for debugging or troubleshooting purposes from log files, debugging files, and other data sources received from customers, to ensure that magnetic stripe data, card validation codes or values, and PINs or PIN block data are not stored on software vendor systems. These data sources must be collected in limited amounts and only when necessary to resolve a problem, encrypted while stored, and deleted immediately after use.

No sensitive card data is ever written to any log files. It is not possible to enable any debugging of any kind.
The PostgreSQL database and Apache webserver are configured _not_ to log _any_ statements, in accordance with the pci-blackbox Implementation Guide.

## 2. Protect stored cardholder data

### 2.1. Software vendor must provide guidance to customers regarding purging of cardholder data after expiration of customer-defined retention period.

Guidance present in the Implementation Guide.

### 2.2. Mask PAN when displayed (the first six and last four digits are the maximum number of digits to be displayed).

No parts of the PANs are ever stored, displayed or logged in plaintext in the pci-blackbox.

### 2.3. Render PAN, at a minimum, unreadable anywhere it is stored.

The PANs are hashed using the standard <code>pgcrypto</code> contrib module distributed with PostgreSQL.
The hashing algorithm is <code>crypt-bf/8</code> which is intentionally slow to prevent brute-force attacks.
According to the [pgcrypto](http://www.postgresql.org/docs/9.2/static/pgcrypto.html) manual, a 1.5GHz Pentium 4 is only able to compute 28 hashes per second.

The PAN hashes never leave the pci-blackbox, instead a unique reference (UUID) is returned to the caller for each unique card number,
which cannot be used to brute-force the card number, as it has no correlation at all with the card number, it's simply a random value.

### 2.4. If disk encryption is used (rather than file- or column-level database encryption), logical access must be managed independently of native operating system access control mechanisms (for example, by not using local user account databases). Decryption keys must not be tied to user accounts.

N/A, the pci-blackbox only uses column-level database encryption.

### 2.5. Payment application must protect cryptographic keys used for encryption of cardholder data against disclosure and misuse.

No encryption keys are ever stored in the pci-blackbox. Instead, the encryption keys are returned to the caller when the card is encrypted.
The caller, i.e. the customer's main system, stores the encryption keys as a reference to the card stored in the pci-blackbox.
Every time the card is being used, the encryption key is passed to the pci-blackbox in order to temporarily decrypt the card data in memory to perform the authorise request.
If the pci-blackbox would be compromised, none of the encrypted data can be retrived, without also breaking into the customer's main system, where the encryption keys are stored.
For card data to be compromised, an attacker must succeed breaking into _both_ systems.

### 2.6. Payment application must implement key management processes and procedures for cryptographic keys used for encryption of cardholder data.

N/A, cryptographic keys are not stored in the pci-blackbox.

### 2.7. Securely delete any cryptographic key material or cryptogram stored by previous versions of the payment application, in accordance with industry-accepted standards for secure deletion, as defined, for example the list of approved products maintained by the National Security Agency, or by other State or National standards or regulations. These are cryptographic keys used to encrypt or verify cardholder data.

N/A, the pci-blackbox has never permanentely stored any such data in any version.

## 3. Provide secure authentication features

### 3.1. The “out of the box” installation of the payment application in place at the completion of the installation process, must facilitate use of unique user IDs and secure authentication (defined at PCI DSS Requirements 8.1, 8.2, and 8.5.8–8.5.15) for all administrative access and for all access to cardholder data.

Each user account is assgined a unique ID, i.e. the Linux username. Secure authentication is required using SSH and public/private RSA keys.

No default passwords are ever present anywhere in the pci-blackbox.

Not even an administrator with root access is able to get hold of any sensitive card data as everything is encrypted.

### 3.2. Access to PCs, servers, and databases with payment applications must require a unique user ID and secure authentication.

Each user account is assgined a unique ID, i.e. the Linux username. Secure authentication is required using SSH and public/private RSA keys.
Access to the PostgreSQL database can only be made from localhost, i.e. the user must connect to the pci-blackbox via SSH and then connect from the shell to the database.

### 3.3. Render payment application passwords unreadable during transmission and storage, using strong cryptography based on approved standards

Passwords are not used anywhere in the system, instead users authenticate using SSH public/private RSA keys.
Communication via SSH is encrypted using strong cryptography.

# 4. Log payment application activity

## 4.1. At the completion of the installation process, the “out of the box” default installation of the payment application must log all user access (especially users with administrative privileges), and be able to link all activities to individual users.

All connections to the pci-blackbox are logged using the standard Linux daemon <code>syslogd</code> to the file <code>/var/log/auth.log</code>.

## 4.2. Payment application must implement an automated audit trail to track and monitor access.

Logging cannot be disabled according to the Implementation Guide. If they customer would disable it anyway, the customer is warned doing so will result in non-compliance with PCI DSS.

# 5. Develop secure payment applications

## 5.1. Develop all payment applications in accordance with PCI DSS (for example, secure authentication and logging) and based on industry best practices and incorporate information security throughout the software development life cycle. These processes must include the following:

### 5.1.1. Testing of all security patches and system and software configuration changes before deployment, including but not limited to testing for the following.

#### 5.1.1.1. Validation of all input (to prevent cross-site scripting, injection flaws, malicious file execution, etc.)

#### 5.1.1.2. Validation of proper error handling

#### 5.1.1.3. Validation of secure cryptographic storage

#### 5.1.1.4. Validation of secure communications

#### 5.1.1.5. Validation of proper role-based access control (RBAC)

### 5.1.2. Separate development/test, and production environments.

### 5.1.3. Separation of duties between development/test, and production environments

### 5.1.4. Live PANs are not used for testing or development

### 5.1.5. Removal of test data and accounts before production systems become active

### 5.1.6. Removal of custom payment application accounts, user IDs, and passwords before payment applications are released to customers

### 5.1.7. Review of payment application code prior to release to customers after any significant change, to identify any potential coding vulnerability.

## 5.2. Develop all web payment applications (internal and external, and including web administrative access to product) based on secure coding guidelines such as the Open Web Application Security Project Guide. Cover prevention of common coding vulnerabilities in software development processes, to include:

### 5.2.1. Cross-site scripting (XSS)

### 5.2.2. Injection flaws, particularly SQL injection. Also consider LDAP and Xpath injection flaws, as well as other injection flaws

### 5.2.3. Malicious file execution

### 5.2.4. Insecure direct object references

### 5.2.5. Cross-site request forgery (CSRF)

### 5.2.6. Information leakage and improper error handling

### 5.2.7. Broken authentication and session management

### 5.2.8. Insecure cryptographic storage 

### 5.2.9. Insecure communications

### 5.2.10. Failure to restrict URL access

## 5.3. Software vendor must follow change control procedures for all product software configuration changes. The procedures must include the following:

### 5.3.1. Documentation of impact

### 5.3.2. Management sign-off by appropriate parties

### 5.3.3. Testing of operational functionality

### 5.3.4. Back-out or product de-installation procedures

## 5.4. The payment application must not use or require use of unnecessary and insecure services and protocols (for example, NetBIOS, file-sharing, Telnet, unencrypted FTP, etc.).

# 6. Protect wireless transmissions

## 6.1 For payment applications using wireless technology, the wireless technology must be implemented securely.

## 6.2. For payment applications using wireless technology, payment application must facilitate use of industry best practices (for example, IEEE 802.11i) to implement strong encryption for authentication and transmission.

# 7. Test payment applications to address vulnerabilities 

## 7.1. Software vendors must establish a process to identify newly discovered security vulnerabilities (for example, subscribe to alert services freely available on the Internet) and to test their payment applications for vulnerabilities. Any underlying software or systems that are provided with or required by the payment application (for example, web servers, 3rd-party libraries and programs) must be included in this process.

## 7.2. Software vendors must establish a process for timely development and deployment of security patches and upgrades, which includes delivery of updates and patches in a secure manner with a known chain-of-trust, and maintenance of the integrity of patch and update code during delivery and deployment.

# 8. Facilitate secure network implementation 

## 8.1. 1 The payment application must be able to be implemented into a secure network environment. Application must not interfere with use of devices, applications, or configurations required for PCI DSS compliance.

# 9. Cardholder data must never be stored on a server connected to the Internet

## 9.1. The payment application must be developed such that the database server and web server are not required to be on the same server, nor is the database server required to be in the DMZ with the web server.

# 10. Facilitate secure remote software updates 

## 10.1. If payment application updates are delivered via remote access into customers’ systems, software vendors must tell customers to turn on remote-access technologies only when needed for downloads from vendor, and to turn off immediately after download completes. Alternatively, if delivered via VPN or other highspeed connection, software vendors must advise customers to properly configure a firewall or a personal firewall product to secure “always-on” connections.

# 11. Facilitate secure remote access to payment application

## 11.1. The payment application must not interfere with use of a two-factor authentication mechanism. The payment application must allow for technologies such as RADIUS or TACACS with tokens, or VPN with individual certificates.

## 11.2. If the payment application may be accessed remotely, remote access to the payment application must be authenticated using a twofactor authentication mechanism.

## 11.3. If vendors, resellers/integrators, or customers can access customers’ payment applications remotely, the remote access must be implemented securely.

# 12. Encrypt sensitive traffic over public networks 

## 12.1. If the payment application sends, or facilitates sending, cardholder data over public networks, the payment application must support use of strong cryptography and security protocols such as SSL/TLS and Internet protocol security (IPSEC) to safeguard sensitive cardholder data during transmission over open, public networks.

## 12.2. The payment application must never send unencrypted PANs by end-user messaging technologies (for example, e-mail, instant messaging, chat).

# 13. Encrypt all non-console administrative access

## 13.1. Instruct customers to encrypt all non-console administrative access using technologies such as SSH, VPN, or SSL/TLS for web-based management and other non-console administrative access.

# 14. Maintain instructional documentation and training programs for customers, resellers, and integrators

## 14.1. Develop, maintain, and disseminate a PADSS Implementation Guide(s) for customers, resellers, and integrators that accomplishes the following:

### 14.1.1. Addresses all requirements in this document wherever the PA-DSS Implementation Guide is referenced.

### 14.1.2. Includes a review at least annually and updates to keep the documentation current with all major and minor software changes as well as with changes to the requirements in this document.

## 14.2. Develop and implement training and communication programs to ensure payment application resellers and integrators know how to implement the payment application and related systems and networks according to the PA-DSS Implementation Guide and in a PCI DSScompliant manner.

### 14.2.1. Update the training materials on an annual basis and whenever new payment application versions are released.





