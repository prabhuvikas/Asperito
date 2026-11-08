# Asperito GitHub repository naming

The public name is **Asperito**; the internal Xcode target stays **FrameGuide**. The documentation and product page links now target `https://github.com/prabhuvikas/Asperito` and `https://prabhuvikas.github.io/Asperito/`.

## One GitHub administration step still required

Open https://github.com/prabhuvikas/FrameGuide/settings and change **Repository name** from `FrameGuide` to `Asperito`, then confirm. This admin-only operation is not supported by the connected GitHub tools.

After renaming, open repository **Settings → Pages → Build and deployment**; choose **GitHub Actions**. Then rerun the `Asperito Website + Screenshots` workflow. Do not claim the new Pages URL is live until deployment finishes.

All internal Xcode paths, app bundle identifiers, and CI build commands intentionally remain FrameGuide to avoid breaking builds. GitHub normally redirects old repository links, but the Pages site path changes with repository name.
