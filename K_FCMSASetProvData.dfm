inherited K_FormCMSASetProviderData: TK_FormCMSASetProviderData
  Left = 83
  Top = 363
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'New Dentist '
  ClientHeight = 172
  ClientWidth = 481
  OldCreateOrder = True
  OnCloseQuery = FormCloseQuery
  PixelsPerInch = 96
  TextHeight = 13
  object LbTitle: TLabel [0]
    Left = 10
    Top = 12
    Width = 20
    Height = 13
    Caption = 'Title'
  end
  inherited BFMinBRPanel: TPanel
    Left = 469
    Top = 160
  end
  object BtOK: TButton
    Left = 335
    Top = 139
    Width = 65
    Height = 23
    Anchors = [akRight, akBottom]
    Caption = '&OK'
    ModalResult = 1
    TabOrder = 1
  end
  object BtCancel: TButton
    Left = 408
    Top = 139
    Width = 65
    Height = 23
    Anchors = [akRight, akBottom]
    Caption = '&Cancel'
    ModalResult = 2
    TabOrder = 2
  end
  object CmBTitle: TComboBox
    Left = 72
    Top = 8
    Width = 58
    Height = 21
    Style = csDropDownList
    Color = 10682367
    ItemHeight = 13
    ItemIndex = 7
    TabOrder = 3
    Items.Strings = (
      'Dr'
      'Master'
      'Miss'
      'Mr'
      'Mrs'
      'Ms'
      'Prof'
      '')
  end
  object LbESurname: TLabeledEdit
    Left = 72
    Top = 40
    Width = 401
    Height = 21
    Anchors = [akTop, akRight]
    Color = 10682367
    EditLabel.Width = 60
    EditLabel.Height = 13
    EditLabel.Caption = 'Surname      '
    LabelPosition = lpLeft
    MaxLength = 40
    TabOrder = 4
    OnExit = LbESurnameExit
    OnKeyDown = LbESurnameKeyDown
  end
  object LbEFirstname: TLabeledEdit
    Left = 72
    Top = 72
    Width = 401
    Height = 21
    Anchors = [akTop, akRight]
    Color = 10682367
    EditLabel.Width = 60
    EditLabel.Height = 13
    EditLabel.Caption = 'First name    '
    LabelPosition = lpLeft
    MaxLength = 40
    TabOrder = 5
    OnExit = LbESurnameExit
    OnKeyDown = LbESurnameKeyDown
  end
  object LbEMiddle: TLabeledEdit
    Left = 72
    Top = 104
    Width = 401
    Height = 21
    Anchors = [akTop, akRight]
    Color = 10682367
    EditLabel.Width = 61
    EditLabel.Height = 13
    EditLabel.Caption = 'Middle          '
    LabelPosition = lpLeft
    MaxLength = 40
    TabOrder = 6
    OnExit = LbESurnameExit
    OnKeyDown = LbESurnameKeyDown
  end
  object BtWEBAccount: TButton
    Left = 168
    Top = 7
    Width = 137
    Height = 23
    Caption = 'WEB Account details'
    TabOrder = 7
    OnClick = BtWEBAccountClick
  end
  object BtSecurity: TButton
    Left = 344
    Top = 7
    Width = 129
    Height = 23
    Caption = 'Security limitations '
    TabOrder = 8
    OnClick = BtSecurityClick
  end
end
