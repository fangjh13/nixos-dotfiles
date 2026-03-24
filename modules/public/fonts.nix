{pkgs}:
with pkgs; [
  # icon fonts
  material-design-icons
  font-awesome

  # Noto 系列字体是 Google 主导的，名字的含义是「没有豆腐」（no tofu），因为缺字时显示的方框或者方框被叫作 tofu
  # Noto 系列字族名只支持英文，命名规则是 Noto + Sans 或 Serif + 文字名称。
  # 其中汉字部分叫 Noto Sans/Serif CJK SC/TC/HK/JP/KR，最后一个词是地区变种。
  noto-fonts # 大部分文字的常见样式，不包含汉字
  noto-fonts-cjk-sans # 汉字部分
  noto-fonts-cjk-serif
  noto-fonts-color-emoji # 彩色的表情符号字体
  noto-fonts-emoji-blob-bin # 另一种彩色表情符号字体，blob 是 Google 的表情符号设计团队
  # noto-fonts-extra # 提供额外的字重和宽度变种

  # 思源系列字体是 Adobe 主导的。其中汉字部分被称为「思源黑体」和「思源宋体」，是由 Adobe + Google 共同开发的
  # source-sans # 无衬线字体，不含汉字。字族名叫 Source Sans 3 和 Source Sans Pro，以及带字重的变体，加上 Source Sans 3 VF
  # source-serif # 衬线字体，不含汉字。字族名叫 Source Code Pro，以及带字重的变体
  source-han-sans # 思源黑体
  source-han-serif # 思源宋体

  # Liberation fonts
  liberation_ttf

  # Mozilla Fira Sans
  fira
  fira-code-symbols

  # Google Android Fonts
  roboto
  open-sans

  # DejaVu fonts
  dejavu_fonts

  # symbols icon only
  nerd-fonts.symbols-only
  # Characters
  nerd-fonts.noto
  nerd-fonts.hack
  nerd-fonts.jetbrains-mono
  nerd-fonts.fira-code
  nerd-fonts.fira-mono
  nerd-fonts.roboto-mono
  nerd-fonts.dejavu-sans-mono
]
