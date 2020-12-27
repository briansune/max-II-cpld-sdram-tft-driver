# max_ii_cpld_sdram_tft_driver

## This project no longer cont'd update as read back and write functions are completed.

## Please provide pull requests to cont'd this project if any serious issues.

MAX II Altera's CPLD TFT driver design with SDRAM and 8080 user interface supported.

The TFT model that is using in this design is AT070N92/94.

This controller support 8 display frames, which utilize the internal SDRAM 4 Banks (2 bits) and MSb of the Row address.

Please feel free to pull requests, update, and improve the design.

A micro example, the STM32F103 demonstartes how to control the CPLD-TFT driver (8080 mode).

Have fun~ =]

Here are the images of the TFT with the CPLD-SDRAM driver board:

# Timing:
![Alt text](CPLD_SDRAM_IMG/8080_timing.png?raw=true "Title")

# Demo videos are embedded here:
[![Watch the video](https://img.youtube.com/vi/pepR1S5PcGI/0.jpg)](https://youtu.be/pepR1S5PcGI)
[![Watch the video](https://img.youtube.com/vi/cpD59P0xeOk/0.jpg)](https://youtu.be/cpD59P0xeOk)
[![Watch the video](https://img.youtube.com/vi/kqaz-9eUTyE/0.jpg)](https://youtu.be/kqaz-9eUTyE)

# Some demo images:
![Alt text](CPLD_SDRAM_IMG/cpld_sdram_tft_img1.jpg?raw=true "Title")
![Alt text](CPLD_SDRAM_IMG/cpld_sdram_tft_img2.jpg?raw=true "Title")
![Alt text](CPLD_SDRAM_IMG/cpld_sdram_tft_img3.jpg?raw=true "Title")


