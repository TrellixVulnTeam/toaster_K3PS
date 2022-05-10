# Colors
GREY='\033[0;37m'
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
MAGENTA='\033[1;35m'
RESET='\033[0m' # No Color

# OS
OS=$(uname)

# Get the options
download=true

while getopts ":c" option; do
    case $option in
    # c is an option which allows you to use toaster from whichever directory you are running this script from
    # this is intended mainly for developers as the repo may be either private or outdated
    # you also won't have to reinstall everytime you change something
    c)
        download=false
        SOURCE_DIR=$PWD
        ;;
    esac
done

# Check if toaster is already installed
[ -d "$HOME/.toaster" ] && echo -e "${GREEN}Toaster is already installed! 🍞${RESET}" && exit

# The actual installler starts here
echo -e "${GREEN}:: Welcome to the toaster installer! 🍞"
echo -e ":: This script will download and install toaster and add it to your path${RESET}"
echo -e "${GREY}Unless you otherwise specified, everything will be installed to $HOME/.toaster${RESET}\n"
printf "${MAGENTA}Press enter to continue or Ctrl+C to cancel!${RESET}"
read -p " "

echo -e "${GREY}Making ~/.toaster directory...${RED}"
mkdir ~/.toaster

# Download
if $download; then
    SOURCE_DIR="$HOME/.toaster/toaster"

    echo -e "${GREEN}Downloading toaster...${RESET}"
    git clone https://github.com/lovebagels/toaster ~/.toaster/toaster || exit 1
else
    echo -e "${YELLOW}Using toaster from current directory...${RESET}"
fi

# Download/install dependencies
python3 -m pip install \
    GitPython \
    atomicwrites \
    click \
    click-aliases \
    filelock \
    requests \
    toml \
    tqdm \
    validators

# Install
echo -e "${GREY}Copying default bakeries....${RED}"
cp $SOURCE_DIR/defaults/bakery.json ~/.toaster/bakery.json

echo -e "${GREY}Making subdirectories...${RED}"
cd ~/.toaster
mkdir .cache apps bakery binaries bin packages package_data
printf $RESET

if [[ "$PATH" =~ (^|:)"$HOME/.toaster/bin"(:|$) ]]; then
    echo -e "${YELLOW}Toaster is already in your path. Horray! 🎉${RESET}"
else
    echo -e "Adding toaster to your path..."

    pathexport='\n# Add toaster to path :)\nexport PATH="$HOME/.toaster/bin:$PATH"\n'
    echo $pathexport >>~/.zshrc
    echo $pathexport >>~/.bashrc

    echo -e "${GREEN}Toaster was added to your path. Horray! 🎉${RESET}"
fi

# Link toaster itself to toaster PATH
ln -sf $SOURCE_DIR/src/toaster/cli.py ~/.toaster/bin/toaster
chmod +x ~/.toaster/bin/toaster

echo -e "${GREEN}Toaster has been installed! 🍞 :)${RESET}"
