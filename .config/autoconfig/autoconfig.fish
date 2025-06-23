#!/usr/bin/env fish

#values
#colors

#control color is used to generate the color palette
#is chosen at random;
#you can also set it manually like so:
#set base "#8e2530"
set base $(pastel random -n 1| pastel format);

#trim the hashtag
set base $(string sub -s 2 $base);

#the higher, the bigger the contrast
set diff_factor 10;

#wether the theme should be dark or light, chosen at random
#0 means dark, 1 means light
set theme $(math "$(random) % 2");
#set theme 1

set SEARCH  "BG" "LIGHT"  "DARKER" "TEXT" "PRIMARY" "SECONDARY" "ACCENT" "GREY";

#create colors using pastel
#different sets of commands depeding on the theme

#the background colors are theme dependant

#set the luminance factor between the different background shades
set bg_factor  0.1
set bg_base_value 0.35

#used to darken or lighten
if test $theme -eq 0
  echo "theme is 0, mapping to -1"
  set theme "-1"
end

echo "theme is $theme"

#background
set REPLACE          $(echo $base | pastel darken -- $(math "$theme * ($bg_base_value)") | pastel format);

#baackground lighter
set REPLACE $REPLACE $(echo $base | pastel darken -- $(math "$theme * ($bg_base_value + $bg_factor)") | pastel rotate 15 | pastel format);

#background darker
set REPLACE $REPLACE $(echo $base | pastel darken -- $(math "$theme * ($bg_base_value - $bg_factor)") | pastel rotate 345 | pastel format);

#text color, we use the background color to determine the textcolor
set REPLACE $REPLACE $(echo $REPLACE[1] | pastel textcolor | pastel format);

#primary color
set REPLACE $REPLACE $(echo $base | pastel rotate $(math "2 * $diff_factor") | pastel format);

#secondary color
set REPLACE $REPLACE $(echo $base | pastel rotate $(math "5 * $diff_factor") | pastel format);

#accent color
set REPLACE $REPLACE $(echo $base | pastel lighten 0.1 | pastel rotate $(math "7 * $diff_factor") | pastel format);

#gray
set REPLACE $REPLACE "$(echo $base | pastel to-gray | pastel format)";

#remove the '#' in the color names
#and write the colors
echo "base: $base"
echo $base | pastel color

for i in (seq $(count $REPLACE))
  set REPLACE[$i] $(string sub -s 2 $REPLACE[$i])
  echo "color: $SEARCH[$i]"
  echo $REPLACE[$i] | pastel color
end

#fonts
set SEARCH $SEARCH "FONT_SIZE_TEXT" "FONT_SIZE_BIG" "FONT_SIZE_SMALL" "FONT_PATH" "FONT_NAME";
set REPLACE $REPLACE "12" "18" "8" "\\/usr\\/share\\/fonts\\/cascadia\\/CaskaydiaCoveNerdFontMono-Regular.ttf" "CaskaydiaCove Nerd Font Mono";

#other
set SEARCH $SEARCH "BORDER_RADIUS" "BORDER_RADIUS_SMALL" "PADDING";
set REPLACE $REPLACE "8" "4" "5";

#copy the placeholder files
rm -rf ~/.config/autoconfig/temp;
mkdir ~/.config/autoconfig/temp;
for file in ~/.config/autoconfig/configs/*.config;
  cp $file ~/.config/autoconfig/temp;
end;

#replace the placeholders with their values in the new files
for file in ~/.config/autoconfig/temp/*.config;
  for i in (seq 1 (count $SEARCH));
    sed -i -e "s/!$SEARCH[$i]/$REPLACE[$i]/g" $file;
  end;
end;

#move the modified files to the correct locations
cp ~/.config/autoconfig/temp/river.config ~/.config/river/init;
cp ~/.config/autoconfig/temp/yambar.config ~/.config/yambar/config.yml;
cp ~/.config/autoconfig/temp/tofi.config ~/.config/tofi/config;
cp ~/.config/autoconfig/temp/foot.config ~/.config/foot/foot.ini;
cp ~/.config/autoconfig/temp/kitty.config ~/.config/kitty/kitty.conf;
cp ~/.config/autoconfig/temp/gowall-theme.config ~/.config/autoconfig/temp/gowall-theme.json
cp ~/.config/autoconfig/temp/nvim.config ~/.local/share/nvim/lazy/base46/lua/base46/themes/cac.lua
cp ~/.config/autoconfig/temp/firefox.config ~/.mozilla/firefox/9cyj5jh8.default-release/chrome/userChrome.css

#generate the background based on the color
gowall convert ~/.config/autoconfig/pictures/original.jpg -t ~/.config/autoconfig/temp/gowall-theme.json --output ~/.config/autoconfig/pictures/generated.jpg > ~/.config/autoconfig/log/gowall.log 2> ~/.config/autoconfig/log/gowall.log 

#refresh the required settings
pkill yambar; #required to avoidf having multiple yambars
pkill wideriver; #required for  proper refresh
pkill swaybg; #required for  proper refresh
sh ~/.config/river/init > ~/.config/autoconfig/log/river.log; #refresh river;

