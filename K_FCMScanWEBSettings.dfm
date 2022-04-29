inherited K_FormCMScanWEBSettings: TK_FormCMScanWEBSettings
  Left = 379
  Top = 379
  BorderStyle = bsDialog
  Caption = 'WEB Settings'
  ClientHeight = 288
  ClientWidth = 536
  OldCreateOrder = True
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  inherited BFMinBRPanel: TPanel
    Left = 526
    Top = 278
    TabOrder = 4
  end
  object ChBWEBMode: TCheckBox
    Left = 18
    Top = 16
    Width = 175
    Height = 17
    Caption = 'WEB Mode'
    TabOrder = 0
    OnClick = ChBWEBModeClick
  end
  object LbEdPortNumber: TLabeledEdit
    Left = 18
    Top = 48
    Width = 399
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    Color = 10682367
    EditLabel.Width = 72
    EditLabel.Height = 13
    EditLabel.Caption = '  Port number   '
    LabelPosition = lpRight
    TabOrder = 1
    OnChange = LbEdPortNumberChange
  end
  object BtRun: TButton
    Left = 367
    Top = 255
    Width = 75
    Height = 23
    Anchors = [akRight, akBottom]
    Caption = 'OK'
    ModalResult = 1
    TabOrder = 2
  end
  object BtExit: TButton
    Left = 447
    Top = 255
    Width = 75
    Height = 23
    Anchors = [akRight, akBottom]
    Caption = 'Exit'
    ModalResult = 2
    TabOrder = 3
  end
  object LbEdWDDrive: TLabeledEdit
    Left = 18
    Top = 80
    Width = 399
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    Color = 10682367
    EditLabel.Width = 84
    EditLabel.Height = 13
    EditLabel.Caption = '  WEB DAV Drive'
    LabelPosition = lpRight
    TabOrder = 5
    OnChange = LbEdWDDriveChange
  end
  object LbEdWDHost: TLabeledEdit
    Left = 18
    Top = 112
    Width = 399
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    Color = 10682367
    EditLabel.Width = 81
    EditLabel.Height = 13
    EditLabel.Caption = '  WEB DAV Host'
    LabelPosition = lpRight
    TabOrder = 6
  end
  object LbEdWDLogin: TLabeledEdit
    Left = 18
    Top = 144
    Width = 399
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    Color = 10682367
    EditLabel.Width = 85
    EditLabel.Height = 13
    EditLabel.Caption = '  WEB DAV Login'
    LabelPosition = lpRight
    TabOrder = 7
  end
  object LbEdWDPassword: TLabeledEdit
    Left = 18
    Top = 176
    Width = 399
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    Color = 10682367
    EditLabel.Width = 105
    EditLabel.Height = 13
    EditLabel.Caption = '  WEB DAV Password'
    LabelPosition = lpRight
    PasswordChar = '*'
    TabOrder = 8
  end
  object LbEdWDCompID: TLabeledEdit
    Left = 18
    Top = 208
    Width = 399
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    Color = 10682367
    EditLabel.Width = 65
    EditLabel.Height = 13
    EditLabel.Caption = '  Computer ID'
    LabelPosition = lpRight
    TabOrder = 9
  end
  object LbEdWDDateOut: TLabeledEdit
    Left = 18
    Top = 248
    Width = 199
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    Color = 10682367
    EditLabel.Width = 43
    EditLabel.Height = 13
    EditLabel.Caption = 'Date Out'
    LabelPosition = lpRight
    TabOrder = 10
    Visible = False
  end
end
