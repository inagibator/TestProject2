inherited K_FormCMNewDBAPSW: TK_FormCMNewDBAPSW
  Left = 498
  Top = 505
  BorderStyle = bsDialog
  Caption = 'Change Password'
  ClientHeight = 183
  ClientWidth = 331
  OldCreateOrder = True
  PixelsPerInch = 96
  TextHeight = 13
  inherited BFMinBRPanel: TPanel
    Left = 321
    Top = 173
    TabOrder = 3
  end
  object LbEdOldPSW: TLabeledEdit
    Left = 16
    Top = 24
    Width = 305
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    Color = 10682367
    EditLabel.Width = 64
    EditLabel.Height = 13
    EditLabel.Caption = '&Old password'
    PasswordChar = '*'
    TabOrder = 0
    OnChange = LbEdOldPSWChange
  end
  object BtRun: TButton
    Left = 162
    Top = 150
    Width = 75
    Height = 23
    Anchors = [akRight, akBottom]
    Caption = 'OK'
    TabOrder = 1
    OnClick = BtRunClick
  end
  object BtExit: TButton
    Left = 244
    Top = 150
    Width = 75
    Height = 23
    Anchors = [akRight, akBottom]
    Caption = 'Exit'
    ModalResult = 2
    TabOrder = 2
  end
  object BtForgotPSW: TButton
    Left = 186
    Top = 3
    Width = 134
    Height = 19
    Anchors = [akTop, akRight]
    Caption = 'Forgot old password?'
    TabOrder = 4
    OnClick = BtForgotPSWClick
  end
  object LbEdNewPSW: TLabeledEdit
    Left = 16
    Top = 72
    Width = 305
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    Color = 10682367
    EditLabel.Width = 70
    EditLabel.Height = 13
    EditLabel.Caption = '&New password'
    PasswordChar = '*'
    TabOrder = 5
    OnChange = LbEdOldPSWChange
  end
  object LbEdVerifyPSW: TLabeledEdit
    Left = 16
    Top = 120
    Width = 305
    Height = 22
    Anchors = [akLeft, akTop, akRight]
    Color = 10682367
    EditLabel.Width = 74
    EditLabel.Height = 13
    EditLabel.Caption = '&Verify password'
    PasswordChar = '*'
    TabOrder = 6
    OnChange = LbEdOldPSWChange
  end
end
