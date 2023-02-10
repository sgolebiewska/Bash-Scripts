#!/bin/bash
# Author           : Sandra Golebiewska
# Created On       : 15.12.2022
# Last Modified By : Sandra Golebiewska
# Last Modified On : 24.01.2023
# Version          : v1.0
#
# Description      : Script used to add watermarks to images in a selected folder
# 
#
# Licensed under GPL (see /usr/share/common-licenses/GPL for more # details or contact

#-v and -h options
while getopts "vh" opt; do
  case $opt in
    v)
        echo "Mass adding watermark version 1 Sandra Golebiewska"
        exit 0
        ;;
    h)
        echo "Navigation: 
    -v  version and author information
    -h  help message
This script is used to mass add watermark on a folder containing images. Follow the instructions popping on the screen to properly add the watermark.
If the script doesn't work:
Fedora: sudo dnf install ImageMagick
Mint: sudo apt-get install ImageMagick"
        exit 0
        ;;
    \*)
        echo "Invalid option: -$OPTARG"
        exit 1
        ;;
  esac
done

#welcome message
ans=$(zenity --question \
	         --title "Mass Adding Watermarks" \
	         --text="Welcome!:) This script will add watermark to your images. It will not delete the images:)"; echo $?;)
if [ "$ans" = 0 ]; then 

#choosing the folder
FOLDER=$(zenity --file-selection \
                --directory \
                --title "Select Folder")


#choosing watermark type
W_TYPE=$(zenity --list \
                --title "Select Watermark Type" \
                --column "Type" "Text" "Image")

#choose the actual watermark (according to the chosen type)
if [ "$W_TYPE" = "Text" ]; then
    W_TEXT=$(zenity --entry \
                    --title "Watermark Text" \
                    --text "Enter the text for the watermark:")
    #choose font preferences
    F_SIZE=$(zenity --entry \
                    --title "Font Size" \
                    --text "Enter the font size for the watermark(px):")
    F_COLOR=$(zenity --color-selection \
                     --title "Font Color" \
                     --color=white)
else
    W_IMAGE=$(zenity --file-selection \
                     --title "Select Watermark Image")
    FORMAT=`echo $W_IMAGE | cut -f2 -d.`
    if [[ "$FORMAT" = "jpeg" ]] || [[ "$FORMAT" = "jpg" ]]; then
    #choose the scale and opacity
        SCALE=$(zenity --scale \
                       --min-value=10 --max-value=500 --value=100 --step 10 \
	                   --title='BatchWatermark' --text='Size of watermark image (%):' ); 
        OPACITY=$(zenity --scale \
                         --min-value=10 --max-value=100 --value=50 --step 5 \
	                     --title='BatchWatermark' --text='Opacity of watermark image (%):'); 
    else 
    #if the user chooses wrong file type
        zenity --info --timeout=2 --width=200\
	    --title "Mass Adding Watermarks" \
	    --text "Script error!:( You have chosen wrong file type"  
    exit 0
    fi
fi

#set gravity of the watermark(is used with text as well as the images)
GRAVITY=$(zenity  --list \
	--width=300 \
	--height=340 \
	--title "Mass Adding Watermarks" \
	--text "Select watermark position:" \
	--column "Command" --column "Position" --hide-column "1" \
	Center "Center" \
	NorthEast "Top Right" \
    North "Top" \
    NorthWest "Top Left" \
	East "Right" \
	SouthEast "Bottom Right" \
	South "Bottom" \
	SouthWest "Bottom Left" \
	West "Left" );  


#do the actual watermarking
for IMAGE in "$FOLDER"/*.{jpg,jpeg}
do
    #cutting the name of the file
    NAME=`echo $IMAGE | cut -f1 -d.`
	FORMAT=`echo $IMAGE | cut -f2 -d.`
    #creating copies(the watermarking operation is applied on the copies so the original photos can be used multiple times)
    cp $IMAGE "$NAME"_watermarked."$FORMAT"
    if [ "$W_TYPE" = "Text" ]; then
        #using imagemagick command
        convert "$NAME"."$FORMAT" -gravity "$GRAVITY" -geometry +0+0 -pointsize "$F_SIZE" -fill "$F_COLOR" -annotate +0+5 "$W_TEXT" "$NAME"_watermarked."$FORMAT"
    else
        #using imagemagick command
        convert "$NAME"."$FORMAT" \( $W_IMAGE -resize $SCALE% -alpha on -channel A -evaluate set $OPACITY% \) -gravity "$GRAVITY" -geometry +0+0 -composite "$NAME"_watermarked."$FORMAT"
    fi

done

#moving photos into a separable folder 
mkdir WatermarkedPhotos
mv *_watermarked.* WatermarkedPhotos

zenity --info --width=200 \
        --title "Mass Adding Watermarks" \
        --text="Congratulations! Process completed:)" --timeout=10

else 
zenity --info --timeout=2 \
	    --title "Mass Adding Watermarks" \
	    --text "Script cancelled:(" 
fi
exit 0

