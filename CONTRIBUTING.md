# Contributing to EmberSpark

Thank you for helping to improve EmberSpark. Bug reports, ideas, translations
and code are all welcome.

## Before you start

- For a bug, open an issue with the steps to reproduce it, your Android
  version and your LNbits version.
- For a larger change or a new feature, please open an issue first so we can
  agree on the approach before you invest time in it.

## Making a change

1. Fork the repository and create a branch for your change.
2. Keep the change focused: one topic per pull request.
3. Make sure the project still builds and passes the checks:

   ```sh
   flutter analyze
   flutter test
   ```

4. Write commit messages as one line per change, starting with an emoji:
   `➕Added ...` for new things, `⭐Updated ...` for changed behaviour,
   `🩹Fixed ...` for bug fixes, `⛔Removed ...` for removed code.
5. Open a pull request and describe what you changed and how you tested it.

## Contributor License Agreement

Before your first pull request can be merged, you need to sign the
[Contributor License Agreement](CLA.md) (CLA). It lets Trepnick Solutions
distribute your contribution as part of EmberSpark, also under other license
terms in the future. You keep the copyright of your work.

Signing is done right on GitHub:

1. When you open your first pull request, a bot posts a comment and the
   "CLA Assistant" check fails.
2. Reply to the pull request with exactly:

   > I have read the CLA Document and I hereby sign the CLA

3. The check turns green. You only need to sign once for all future
   contributions. If the check does not update, comment `recheck`.

## License of contributions

EmberSpark is licensed under the [GNU AGPL v3](LICENSE). Your contributions
are published under the same license, and under the CLA to Trepnick
Solutions.

The EmberSpark name and logo are not covered by the license. If you publish a
fork or modified version, please give it a different name and logo.
