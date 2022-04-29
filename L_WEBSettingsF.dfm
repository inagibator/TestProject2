inherited L_WEBSettingsForm: TL_WEBSettingsForm
  Left = 498
  Top = 505
  BorderStyle = bsDialog
  Caption = 'WEB Settings'
  ClientHeight = 293
  ClientWidth = 337
  OldCreateOrder = True
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel [0]
    Left = 16
    Top = 132
    Width = 55
    Height = 13
    Caption = 'Information:'
  end
  inherited BFMinBRPanel: TPanel
    Left = 327
    Top = 283
    TabOrder = 3
  end
  object LbEdPortNumber: TLabeledEdit
    Left = 16
    Top = 8
    Width = 241
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    Color = 10682367
    EditLabel.Width = 72
    EditLabel.Height = 13
    EditLabel.Caption = '  Port number   '
    LabelPosition = lpRight
    TabOrder = 0
    OnChange = LbEdPortNumberChange
  end
  object BtRun: TButton
    Left = 168
    Top = 260
    Width = 75
    Height = 23
    Anchors = [akRight, akBottom]
    Caption = 'OK'
    ModalResult = 1
    TabOrder = 1
  end
  object BtExit: TButton
    Left = 248
    Top = 260
    Width = 75
    Height = 23
    Anchors = [akRight, akBottom]
    Caption = 'Exit'
    ModalResult = 2
    TabOrder = 2
  end
  object BtDownloadScan: TButton
    Left = 16
    Top = 48
    Width = 241
    Height = 25
    Caption = 'Download Mediasuite Scanner'
    TabOrder = 4
    OnClick = BtDownloadScanClick
  end
  object BtSetScan: TButton
    Left = 16
    Top = 88
    Width = 241
    Height = 25
    Caption = 'Populate the settings to Mediasuite Scanner'
    TabOrder = 5
    OnClick = BtSetScanClick
  end
  object Memo1: TMemo
    Left = 16
    Top = 151
    Width = 307
    Height = 89
    Lines.Strings = (
      'Memo1')
    TabOrder = 6
  end
end
