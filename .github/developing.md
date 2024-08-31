# Developing

## Build

### Publish NPM

```sh
# major | minor | patch
export VERSION_TYPE=patch
# Manual Dev Build Publish : premajor | preminor | prepatch | prerelease
npm --no-git-tag-version version pre${VERSION_TYPE}
# Incremental Build
npm --no-git-tag-version version prerelease
npm publish --tag beta

# Manual Prod Build Publish : major | minor | patch
npm version patch
export VERSION_NOW=v$(npm pkg get version | sed 's/"//g')
git push
git push origin ${VERSION_NOW}
npm publish
```
