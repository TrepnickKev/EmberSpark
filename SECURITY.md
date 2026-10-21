# Security policy

EmberSpark stores the API keys of your LNbits wallets on your phone and can
send payments with them. Security reports are taken seriously and handled
privately.

## Reporting a vulnerability

Please **do not open a public issue** for security problems.

Report them privately through GitHub instead:

1. Open the [Security tab](https://github.com/TrepnickKev/EmberSpark/security)
   of this repository.
2. Click **Report a vulnerability** and describe the problem.

Only the maintainer can see the report. Please include:

- what the problem is and what an attacker could do with it,
- the steps to reproduce it (app version, Android version, LNbits version),
- a proof of concept, if you have one.

You will get a first answer within a few days. Please give us reasonable time
to release a fix before you disclose the issue publicly. You will be credited
in the release notes unless you prefer to stay anonymous.

## Supported versions

Security fixes are made for the latest release only. Please make sure you can
reproduce the problem with the
[latest release](https://github.com/TrepnickKev/EmberSpark/releases/latest).

## Scope

In scope: the EmberSpark app and the code in this repository, for example how
it stores API keys, talks to the LNbits server, handles LNURL, BOLT11, BOLT12
and Bolt Card data, or processes deep links and QR codes.

Out of scope: vulnerabilities in LNbits itself or its extensions (please report
those to the [LNbits project](https://github.com/lnbits/lnbits)), and problems
that require a rooted or already compromised device.
