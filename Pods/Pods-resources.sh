#!/bin/sh

RESOURCES_TO_COPY=${PODS_ROOT}/resources-to-copy.txt
touch "$RESOURCES_TO_COPY"

install_resource()
{
  case $1 in
    *.storyboard)
      echo "ibtool --reference-external-strings-file --errors --warnings --notices --output-format human-readable-text --compile ${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$1\" .storyboard`.storyboardc ${PODS_ROOT}/$1 --sdk ${SDKROOT}"
      ibtool --reference-external-strings-file --errors --warnings --notices --output-format human-readable-text --compile "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$1\" .storyboard`.storyboardc" "${PODS_ROOT}/$1" --sdk "${SDKROOT}"
      ;;
    *.xib)
        echo "ibtool --reference-external-strings-file --errors --warnings --notices --output-format human-readable-text --compile ${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$1\" .xib`.nib ${PODS_ROOT}/$1 --sdk ${SDKROOT}"
      ibtool --reference-external-strings-file --errors --warnings --notices --output-format human-readable-text --compile "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$1\" .xib`.nib" "${PODS_ROOT}/$1" --sdk "${SDKROOT}"
      ;;
    *.framework)
      echo "rsync -rp ${PODS_ROOT}/$1 ${CONFIGURATION_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"
      rsync -rp "${PODS_ROOT}/$1" "${CONFIGURATION_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"
      ;;
    *.xcdatamodeld)
      echo "xcrun momc ${PODS_ROOT}/$1 ${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename $1 .xcdatamodeld`.momd"
      xcrun momc "${PODS_ROOT}/$1" "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename $1 .xcdatamodeld`.momd"
      ;;
    *)
      echo "${PODS_ROOT}/$1"
      echo "${PODS_ROOT}/$1" >> "$RESOURCES_TO_COPY"
      ;;
  esac
}
install_resource 'Google-Maps-iOS-SDK/GoogleMaps.framework/Versions/A/Resources/GoogleMaps.bundle'
install_resource 'MDSpreadView/Images/MDSpreadViewCell.png'
install_resource 'MDSpreadView/Images/MDSpreadViewCell@2x.png'
install_resource 'MDSpreadView/Images/MDSpreadViewCellSelected.png'
install_resource 'MDSpreadView/Images/MDSpreadViewCellSelected@2x.png'
install_resource 'MDSpreadView/Images/MDSpreadViewColumnHeaderLeft.png'
install_resource 'MDSpreadView/Images/MDSpreadViewColumnHeaderLeft@2x.png'
install_resource 'MDSpreadView/Images/MDSpreadViewColumnHeaderLeftSelected.png'
install_resource 'MDSpreadView/Images/MDSpreadViewColumnHeaderLeftSelected@2x.png'
install_resource 'MDSpreadView/Images/MDSpreadViewColumnHeaderRight.png'
install_resource 'MDSpreadView/Images/MDSpreadViewColumnHeaderRight@2x.png'
install_resource 'MDSpreadView/Images/MDSpreadViewColumnHeaderRightSelected.png'
install_resource 'MDSpreadView/Images/MDSpreadViewColumnHeaderRightSelected@2x.png'
install_resource 'MDSpreadView/Images/MDSpreadViewCornerBottomLeft.png'
install_resource 'MDSpreadView/Images/MDSpreadViewCornerBottomLeft@2x.png'
install_resource 'MDSpreadView/Images/MDSpreadViewCornerBottomLeftSelected.png'
install_resource 'MDSpreadView/Images/MDSpreadViewCornerBottomLeftSelected@2x.png'
install_resource 'MDSpreadView/Images/MDSpreadViewCornerBottomRight.png'
install_resource 'MDSpreadView/Images/MDSpreadViewCornerBottomRight@2x.png'
install_resource 'MDSpreadView/Images/MDSpreadViewCornerBottomRightSelected.png'
install_resource 'MDSpreadView/Images/MDSpreadViewCornerBottomRightSelected@2x.png'
install_resource 'MDSpreadView/Images/MDSpreadViewCornerTopLeft.png'
install_resource 'MDSpreadView/Images/MDSpreadViewCornerTopLeft@2x.png'
install_resource 'MDSpreadView/Images/MDSpreadViewCornerTopLeftSelected.png'
install_resource 'MDSpreadView/Images/MDSpreadViewCornerTopLeftSelected@2x.png'
install_resource 'MDSpreadView/Images/MDSpreadViewCornerTopRight.png'
install_resource 'MDSpreadView/Images/MDSpreadViewCornerTopRight@2x.png'
install_resource 'MDSpreadView/Images/MDSpreadViewCornerTopRightSelected.png'
install_resource 'MDSpreadView/Images/MDSpreadViewCornerTopRightSelected@2x.png'
install_resource 'MDSpreadView/Images/MDSpreadViewRowHeaderBottom.png'
install_resource 'MDSpreadView/Images/MDSpreadViewRowHeaderBottom@2x.png'
install_resource 'MDSpreadView/Images/MDSpreadViewRowHeaderBottomSelected.png'
install_resource 'MDSpreadView/Images/MDSpreadViewRowHeaderBottomSelected@2x.png'
install_resource 'MDSpreadView/Images/MDSpreadViewRowHeaderTop.png'
install_resource 'MDSpreadView/Images/MDSpreadViewRowHeaderTop@2x.png'
install_resource 'MDSpreadView/Images/MDSpreadViewRowHeaderTopSelected.png'
install_resource 'MDSpreadView/Images/MDSpreadViewRowHeaderTopSelected@2x.png'

rsync -avr --no-relative --exclude '*/.svn/*' --files-from="$RESOURCES_TO_COPY" / "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
rm "$RESOURCES_TO_COPY"
