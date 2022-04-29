inherited L_WEBCheckVersionForm: TL_WEBCheckVersionForm
  Left = 498
  Top = 505
  BorderStyle = bsDialog
  Caption = 'Upgrade CMScanWEB'
  ClientHeight = 257
  ClientWidth = 530
  OldCreateOrder = True
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  inherited BFMinBRPanel: TPanel
    Left = 529
    Top = 256
    Width = 1
    Height = 1
    TabOrder = 2
  end
  object BtRun: TButton
    Left = 49
    Top = 226
    Width = 75
    Height = 23
    Anchors = [akRight, akBottom]
    Caption = 'OK'
    ModalResult = 1
    TabOrder = 0
    Visible = False
  end
  object BtExit: TButton
    Left = 225
    Top = 226
    Width = 75
    Height = 23
    Anchors = [akRight, akBottom]
    Caption = 'Exit'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Microsoft Sans Serif'
    Font.Style = []
    ModalResult = 2
    ParentFont = False
    TabOrder = 1
    OnClick = BtExitClick
  end
  object Memo1: TMemo
    Left = 16
    Top = 8
    Width = 506
    Height = 161
    Alignment = taCenter
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = 18
    Font.Name = 'Microsoft Sans Serif'
    Font.Style = []
    Lines.Strings = (
      
        'NOTE: The system has detected the installed Mediasuite Scanner v' +
        'ersion '
      'is out of date.'
      
        'Please click the button below to download the up to date version' +
        ' of the '
      'Mediasuite Scanner.'
      'Download the Mediasuite Scanner'
      
        'Once you download the installer please quit your current Mediasu' +
        'ite by right '
      
        'click on the Tray icon and selecting '#8220'Quit Mediasuite Scanner'#8221', ' +
        'and proceed '
      'with the install of a new build.')
    ParentFont = False
    TabOrder = 3
  end
  object Button1: TButton
    Left = 16
    Top = 184
    Width = 201
    Height = 25
    Caption = 'Download the Mediasuite Scanner'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Microsoft Sans Serif'
    Font.Style = []
    ParentFont = False
    TabOrder = 4
    OnClick = Button1Click
  end
  object cbDateOut: TCheckBox
    Left = 370
    Top = 188
    Width = 152
    Height = 17
    Caption = 'Don'#39't show this anymore'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Microsoft Sans Serif'
    Font.Style = []
    ParentFont = False
    TabOrder = 5
  end
end
