inherited K_FormCMSelectMaxPictSize: TK_FormCMSelectMaxPictSize
  Left = 472
  Top = 435
  BorderStyle = bsSingle
  Caption = 'Attach Files'
  ClientHeight = 186
  ClientWidth = 174
  PixelsPerInch = 96
  TextHeight = 13
  inherited BFMinBRPanel: TPanel
    Left = 162
    Top = 174
  end
  object BtOK: TButton
    Left = 8
    Top = 157
    Width = 75
    Height = 23
    Anchors = [akRight, akBottom]
    Caption = '&OK'
    ModalResult = 1
    TabOrder = 1
  end
  object BtCancel: TButton
    Left = 91
    Top = 157
    Width = 75
    Height = 23
    Anchors = [akRight, akBottom]
    Caption = '&Cancel'
    ModalResult = 2
    TabOrder = 2
  end
  object RGSizes: TRadioGroup
    Left = 8
    Top = 8
    Width = 159
    Height = 141
    Anchors = [akLeft, akTop, akRight, akBottom]
    Caption = '  Picture size  '
    ItemIndex = 0
    Items.Strings = (
      'Smaller: 640 x 480'
      'Small: 800 x 600'
      'Medium: 1024 x 768'
      'Large: 1280 x 1024'
      'Original Size')
    TabOrder = 3
  end
end
