# This is free and unencumbered software released into the public domain.

set -e

assets_url=https://spacenerdsinspace.com/snis-assets

curl -O $assets_url/manifest.txt

if ! [[ `git status --porcelain` ]]; then
  echo "No changes in manifest, nothing to do"
  exit
fi

function update_file() {
  sum=$1
  path=`echo "$sum" | awk '{print $2}'`
  if ! md5sum -c <<< $sum
  then
    echo "Downloading $assets_url/$path"
    mkdir -p "`dirname $path`"
    curl "$assets_url/$path" -o "$path"
  fi
}

export assets_url
export -f update_file

echo "Manifest changed, updating..."
parallel < manifest.txt \
   update_file {}

# Sanity check
md5sum -c manifest.txt

today=`date -I`

git add -A
git commit -m "Snapshot $today"
git tag -a $today -m ""
