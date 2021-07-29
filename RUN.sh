#! /bin/bash
#
# (C) 2021, jnweiger@gmail.com, distribute under MIT License
#
# Requires: docker.io dpkg-dev

baseurl="http://localhost/repo"
baseurl="file://$(pwd)/repo"
test -n "$BASEURL" && baseurl="$BASEURL"

plat="$1"
test -z "$plat" && plat="ubuntu-*"

mkdir -p repo
for rel in $plat; do
  docker build -t imei-build-$rel $rel

  # to copy out artefacts, we need a container. docker create creates us one.
  container=$(docker create imei-build-$rel)
  docker cp $container:/usr/local/src repo
  docker rm $container

  rm -rf repo/$rel
  mv repo/src repo/$rel
  ( cd repo/$rel; dpkg-scanpackages . /dev/null > Packages; gzip -9c < Packages > Packages.gz )

  test "$rel" == "ubuntu-21.04" && ln -snf $rel repo/hirsute
  test "$rel" == "ubuntu-20.04" && ln -snf $rel repo/focal
  test "$rel" == "ubuntu-19.10" && ln -snf $rel repo/eoan
  test "$rel" == "ubuntu-19.04" && ln -snf $rel repo/disco
  test "$rel" == "ubuntu-18.10" && ln -snf $rel repo/eoan
  test "$rel" == "ubuntu-18.04" && ln -snf $rel repo/bionic
  test "$rel" == "ubuntu-16.04" && ln -snf $rel repo/xenial
done

packname="imei-imagemagick"
packname_vers=$(find repo -name "${packname}_*.deb" | tail -n 1 | sed -e 's@.*/@@' -e 's@\.deb@@' )

cat <<EOF > repo/index.html
<body style="margin: 20px 50px;">
<H2>Ubuntu packages for $packname_vers</H2>

Run the following shell commands to add the repository and install from there:

<pre>
echo "deb [allow-insecure=yes trusted=yes] $baseurl/\$(. /etc/os-release; echo \$UBUNTU_CODENAME)/ /" | sudo tee /etc/apt/sources.list.d/$packname.list
sudo apt update
sudo apt install $packname
</pre>

<p>
<br>
<hr>
<p>
<br>
<small>
Manual downloads:
<br>
EOF

for dir in $(cd repo; ls -d ubuntu-*); do
  echo >> repo/index.html "<a href=\"$dir\">$dir</a><br>"
done
echo >> repo/index.html "<p><br/><p style=\"text-align: right\">$(date --rfc-3339=seconds)</p>"
