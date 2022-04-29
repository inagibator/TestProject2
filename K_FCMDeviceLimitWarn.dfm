inherited K_FormCMProfileLimitWarn: TK_FormCMProfileLimitWarn
  Left = 111
  Top = 337
  Width = 412
  Height = 189
  BorderStyle = bsSizeToolWin
  Caption = 'Warning'
  PixelsPerInch = 96
  TextHeight = 13
  inherited BFMinBRPanel: TPanel
    Left = 392
    Top = 143
  end
  object DeviceList: TMemo
    Left = 32
    Top = 43
    Width = 363
    Height = 28
    Anchors = [akLeft, akTop, akRight, akBottom]
    BevelInner = bvLowered
    BevelOuter = bvRaised
    BorderStyle = bsNone
    Color = clBtnFace
    ReadOnly = True
    ScrollBars = ssVertical
    TabOrder = 1
  end
  object STTop: TStaticText
    Left = 11
    Top = 8
    Width = 381
    Height = 28
    Anchors = [akLeft, akTop, akRight]
    AutoSize = False
    Caption = 
      'Your Media Suite is licensed to work with %d different imaging d' +
      'evices across the network. You have already reached this number:'
    TabOrder = 2
  end
  object STBottom: TStaticText
    Left = 11
    Top = 78
    Width = 381
    Height = 28
    Anchors = [akLeft, akRight, akBottom]
    AutoSize = False
    Caption = 
      'You can either reduce the number of your installed devises liste' +
      'd above or call your software supplier to change your license. P' +
      'ress OK to continue'
    TabOrder = 3
  end
  object PnCtrl: TPanel
    Left = 8
    Top = 112
    Width = 391
    Height = 33
    Anchors = [akLeft, akRight, akBottom]
    BevelOuter = bvNone
    TabOrder = 4
    DesignSize = (
      391
      33)
    object BtOK: TButton
      Left = 155
      Top = 10
      Width = 75
      Height = 23
      Anchors = []
      Caption = 'OK'
      ModalResult = 2
      TabOrder = 0
    end
  end
end
