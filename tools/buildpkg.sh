#!/bin/bash

#
# tools/buildpkg.sh
#
# Copyright (c) 2014-2015 Simon Fraser University Library
# Copyright (c) 2003-2015 John Willinsky
# Distributed under the GNU GPL v2. For full terms see the file docs/COPYING.
#
# Script to create an OJS package for distribution.
#
# Usage: buildpkg.sh <version> [<tag>]
#
#

GITREP=git://github.com/pkp/ojs.git

if [ -z "$1" ]; then
	echo "Usage: $0 <version> [<tag>-<branch>]";
	exit 1;
fi

VERSION=$1
TAG=$2
PREFIX=ojs
BUILD=$PREFIX-$VERSION
TMPDIR=`mktemp -d $PREFIX.XXXXXX` || exit 1

EXCLUDE="dbscripts/xml/data/locale/en_US/sample.xml		\
dbscripts/xml/data/sample.xml					\
docs/dev							\
locale/te_ST							\
tests								\
tools/buildpkg.sh						\
tools/genLocaleReport.sh					\
tools/genTestLocale.php						\
tools/test							\
lib/pkp/tools/travis						\
lib/pkp/plugins/*/*/tests					\
plugins/*/*/tests						\
plugins/generic/googleAnalytics					\
plugins/generic/phpMyVisites					\
plugins/generic/counter						\
plugins/generic/driver						\
plugins/generic/externalFeed					\
plugins/generic/lucene						\
plugins/generic/openAIRE					\
plugins/generic/coins						\
plugins/auth/ldap						\
plugins/implicitAuth/shibboleth					\
tests								\
lib/pkp/tests							\
.git								\
.openshift							\
lib/pkp/.git							\
lib/pkp/lib/components/*.js					\
lib/pkp/lib/components/*.css					\
lib/pkp/lib/vendor/components					\
lib/pkp/lib/vendor/composer					\
lib/pkp/lib/vendor/ezyang/htmlpurifier/art			\
lib/pkp/lib/vendor/ezyang/htmlpurifier/benchmarks		\
lib/pkp/lib/vendor/ezyang/htmlpurifier/configdog		\
lib/pkp/lib/vendor/ezyang/htmlpurifier/docs			\
lib/pkp/lib/vendor/ezyang/htmlpurifier/extras			\
lib/pkp/lib/vendor/ezyang/htmlpurifier/maintenance		\
lib/pkp/lib/vendor/ezyang/htmlpurifier/smoketests		\
lib/pkp/lib/vendor/ezyang/htmlpurifier/tests			\
lib/pkp/lib/vendor/kriswallsmith				\
lib/pkp/lib/vendor/leafo/lessphp/tests				\
lib/pkp/lib/vendor/leafo/lessphp/docs				\
lib/pkp/lib/vendor/moxiecode/plupload/examples			\
lib/pkp/lib/vendor/phpmailer/phpmailer/docs			\
lib/pkp/lib/vendor/phpmailer/phpmailer/examples			\
lib/pkp/lib/vendor/phpmailer/phpmailer/test			\
lib/pkp/lib/vendor/robloach					\
lib/pkp/lib/vendor/smarty/smarty/demo				\
lib/pkp/lib/vendor/symfony					\
lib/pkp/lib/vendor/phpunit					\
lib/pkp/lib/swordappv2/.git					\
lib/pkp/lib/swordappv2/.git					\
lib/pkp/lib/swordappv2/test"


cd $TMPDIR

echo -n "Cloning $GITREP and checking out tag $TAG ... "
git clone -b $TAG --depth 1 -q -n $GITREP $BUILD || exit 1
cd $BUILD
git checkout -q $TAG || exit 1
echo "Done"

echo -n "Checking out corresponding submodules ... "
git submodule -q update --init --recursive >/dev/null || exit 1
echo "Done"

echo -n "Installing composer dependencies ... "
cd lib/pkp
composer.phar update
cd lib/vendor/oyejorge/less.php
composer.phar update
cd ../../../..
cd ../..

echo -n "Preparing package ... "
cp config.TEMPLATE.inc.php config.inc.php
find . \( -name .gitignore -o -name .gitmodules -o -name .keepme \) -exec rm '{}' \;
rm -rf $EXCLUDE
echo "Done"

cd ..

echo -n "Creating archive $BUILD.tar.gz ... "
tar -zhcf ../$BUILD.tar.gz $BUILD
echo "Done"

cd ..

rm -r $TMPDIR
