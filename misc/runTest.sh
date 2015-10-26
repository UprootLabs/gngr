set -e

rnd() {
  echo `od if=/dev/urandom count=1 2>/dev/null | sha256sum | cut -f1  -d' '`
}

INIT_DIR=`pwd`

# Install fonts
mkdir -p ~/.fonts
cd ~/.fonts
wget "http://www.w3.org/Style/CSS/Test/Fonts/css-testsuite-fonts-v2.zip"
unzip css-testsuite-fonts-v2.zip
rm -rf AhemExtra/
fc-cache -f

cd $INIT_DIR

GRINDER_KEY="$$$(rnd)"

mkdir ~/.gngr

xvfb-run -s "-dpi 96 -screen 0 900x900x24+32" ant -f src/build.xml -Dgngr.grinder.key="$GRINDER_KEY" run &> /dev/null  &

git clone --depth=1 https://github.com/UprootLabs/grinder.git ~/grinder
git clone --depth=1 https://github.com/UprootStaging/grinderBaselines.git ~/grinderBaselines

cp -r ~/grinderBaselines/nightly-unstable ~/grinder

cd ~/grinder
python -m SimpleHTTPServer 8000 &> /dev/null &

sbt "run prepare"
sbt "run compare gngr $GRINDER_KEY"
sbt "run checkBase data ../grinderBaselines/gngr"
