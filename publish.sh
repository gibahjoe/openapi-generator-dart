echo '-------------------------------------------------------'
echo '-------------------------------------------------------'
echo '|                                                     |'
echo '|        PUBLISHING OPENAPI GENERATOR DART            |'
echo '|                                                     |'
echo '-------------------------------------------------------'
echo 'building openapi-generator.jar...'
mvn clean package -f ./openapi-generator-cli/pom.xml
cd openapi-generator-cli || exit
echo 'Publishing openapi-generator-cli... this is just a dry run'
pub get
pub publish --dry-run
read -p "Do you want to publish openapi-generator-cli package to pub? [y/n]" PUBLISH_CLI
if [ "${PUBLISH_CLI}" = "y" ]; then
echo 'Publishing openapi-generator-cli...'
pub publish
echo 'Successfully published openapi cli...'
fi
cd ..

#Openapi generator annotations
cd openapi-generator-annotations || exit
echo 'Publishing openapi-generator-annotations... this is just a dry run'
pub get
pub publish --dry-run
read -p "Do you want to publish openapi-generator-annotations package to pub? [y/n]" PUBLISH_ANNOTATIONS
if [ "${PUBLISH_ANNOTATIONS}" = "y" ]; then
echo 'Publishing openapi-generator-annotations...'
pub publish
echo 'Successfully published openapi generator annotations...'
fi
cd ..

# Openapi Generator
cd openapi-generator || exit
echo 'Publishing openapi-generator... this is just a dry run'
pub get
pub publish --dry-run
read -p "Do you want to publish openapi-generator package to pub? [y/n]" PUBLISH_GENERATOR
if [ "${PUBLISH_GENERATOR}" = "y" ]; then
echo 'Publishing openapi-generator...'
pub publish
echo 'Successfully published openapi generator...'
fi
cd ..
