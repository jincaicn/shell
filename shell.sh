echo '开始打包'

if [ ! -d ./file ];
then
echo '没有就新建存放ipa包的文件夹'
mkdir -p file;
fi
# 当前项目路径
PROJECT_PATH=$(cd "$(dirname "$0")";pwd)

echo '项目路劲--'${PROJECT_PATH}
#fir token
FIR_TOKEN=xxx
APP_KEY=xxx
API_ISSUER=xxx

#项目名
PROJECT_NAME='xxx'
#app名
APP_NAME='xxx'
#scheme 名
SCHEME_NAME='xxx'
#打包模式 Debug/Release
CONFIGURATION=release
#.xcarchive 文件存放路径
ARCHIVE_PATH=${PROJECT_PATH}/file/${PROJECT_NAME}
echo 'xcarchive路劲--'${ARCHIVE_PATH}
#.api 文件存放路径
API_PATH=${PROJECT_PATH}/file/ipa
echo 'api路劲--'${API_PATH}

echo 'exportOptionsPlist路劲--'${EXPORT_OPTIONS_PLIST_PATH}

echo '选择想要打什么包 [1: app-store 2: ad-hoc]'

read number
while( [[ $number != 1 ]] && [[ $number != 2 ]] )
do
echo 'error! 请选择1或2'
read number
done
echo '选择的是'
echo ${number}

#exportOptionsPlist.plist 文件路径
EXPORT_OPTIONS_PLIST_PATH=${PROJECT_PATH}/ExportOptions.plist

if [ $number == 2 ]; then
echo 'ad-hot'
EXPORT_OPTIONS_PLIST_PATH=${PROJECT_PATH}/ExportOptions-adhot.plist
else
echo 'appstore'
EXPORT_OPTIONS_PLIST_PATH=${PROJECT_PATH}/ExportOptions.plist
fi
echo $EXPORT_OPTIONS_PLIST_PATH
echo '///-----------'
echo '/// 正在清理工程'
echo '///-----------'

xcodebuild clean -workspace ${PROJECT_NAME}.xcworkspace -scheme $SCHEME_NAME

echo '///--------'
echo '/// 清理完成'
echo '///--------'
echo ''

echo '--------'
echo '正在 生成 .xcarchive 文件'
xcodebuild \
-workspace ${PROJECT_NAME}.xcworkspace \
-scheme ${SCHEME_NAME} \
-configuration ${CONFIGURATION} \
-archivePath ${ARCHIVE_PATH} \
archive

echo '.xcarchive编译完成'

echo '------'
echo '正在导出ipa 文件'
xcodebuild \
-exportArchive -archivePath ${ARCHIVE_PATH}.xcarchive \
-exportPath ${API_PATH} \
-exportOptionsPlist $EXPORT_OPTIONS_PLIST_PATH

echo ${API_PATH}/${APP_NAME}.ipa

if [ -e ${API_PATH}/${APP_NAME}.ipa ];then

echo 'ipa 包已导入'
else
echo 'ipa 包导入失败'
echo '---------'

echo 'ipa 导出完成'
fi

if [ $number == 1 ]; then
# 上传appstore
echo '正在上传到appstore'
xcrun altool --validate-app -f ${API_PATH}/${APP_NAME}.ipa -t ios --apiKey $APP_KEY --apiIssuer $API_ISSUER --verbose

xcrun altool --upload-app -f ${API_PATH}/${APP_NAME}.ipa  -t ios --apiKey $APP_KEY --apiIssuer $API_ISSUER --verbose
else
echo '正在上传到 fir'
#上传fir
fir login -T $FIR_TOKEN
fir publish ${API_PATH}/${APP_NAME}.ipa
fi

echo '上传成功'