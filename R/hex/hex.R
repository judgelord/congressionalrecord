# install.packages("hexSticker")
# https://thenounproject.com/icon/document-4959325/

library(hexSticker)

hexSticker::sticker("man/figures/sticker.png",
                    package="",
                    p_size=24,
                    p_x = 1,
                    p_y = .6,
                    s_x=1.0, s_y= 1, s_width=.95,
        filename="man/figures/logo.png",
        h_fill="#ffffff", h_color="#000000",
        p_color = "#C5050C")

