inherited K_FormCMSASetPatientData: TK_FormCMSASetPatientData
  Left = 403
  Top = 624
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'New Patient'
  ClientHeight = 290
  ClientWidth = 481
  OldCreateOrder = True
  OnCloseQuery = FormCloseQuery
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object LbTitle: TLabel [0]
    Left = 10
    Top = 12
    Width = 20
    Height = 13
    Caption = 'Title'
  end
  object LbGender: TLabel [1]
    Left = 162
    Top = 11
    Width = 35
    Height = 13
    Caption = 'Gender'
  end
  object LbDOB: TLabel [2]
    Left = 10
    Top = 108
    Width = 23
    Height = 13
    Caption = 'DOB'
  end
  object LbDentist: TLabel [3]
    Left = 10
    Top = 132
    Width = 33
    Height = 13
    Caption = 'Dentist'
  end
  inherited BFMinBRPanel: TPanel
    Left = 469
    Top = 278
    TabOrder = 2
  end
  object BtOK: TButton
    Left = 335
    Top = 257
    Width = 65
    Height = 23
    Anchors = [akRight, akBottom]
    Caption = '&OK'
    ModalResult = 1
    TabOrder = 3
  end
  object BtCancel: TButton
    Left = 408
    Top = 257
    Width = 65
    Height = 23
    Anchors = [akRight, akBottom]
    Caption = '&Cancel'
    ModalResult = 2
    TabOrder = 4
  end
  object CmBTitle: TComboBox
    Left = 72
    Top = 8
    Width = 58
    Height = 21
    Style = csDropDownList
    Color = 10682367
    ItemHeight = 13
    TabOrder = 5
    OnChange = CmBTitleChange
    Items.Strings = (
      'Dr'
      'Master'
      'Miss'
      'Mr'
      'Mrs'
      'Ms'
      'Prof')
  end
  object CmBGender: TComboBox
    Left = 200
    Top = 8
    Width = 37
    Height = 21
    Style = csDropDownList
    Color = 10682367
    ItemHeight = 13
    ItemIndex = 0
    TabOrder = 6
    Text = 'M'
    Items.Strings = (
      'M'
      'F')
  end
  object LbECardNum: TLabeledEdit
    Left = 400
    Top = 8
    Width = 73
    Height = 21
    Anchors = [akTop, akRight]
    Color = 10682367
    EditLabel.Width = 39
    EditLabel.Height = 13
    EditLabel.Caption = 'Card No'
    LabelPosition = lpLeft
    MaxLength = 9
    TabOrder = 7
    Text = '999999999'
    OnChange = LbECardNumChange
  end
  object LbESurname: TLabeledEdit
    Left = 72
    Top = 32
    Width = 401
    Height = 21
    Anchors = [akTop, akRight]
    Color = 10682367
    EditLabel.Width = 60
    EditLabel.Height = 13
    EditLabel.Caption = 'Surname      '
    LabelPosition = lpLeft
    MaxLength = 40
    TabOrder = 8
    OnExit = LbEditControlAutoCapitalExit
    OnKeyDown = LbEditControlAutoCapitalKeyDown
  end
  object LbEFirstname: TLabeledEdit
    Left = 72
    Top = 56
    Width = 401
    Height = 21
    Anchors = [akTop, akRight]
    Color = 10682367
    EditLabel.Width = 60
    EditLabel.Height = 13
    EditLabel.Caption = 'First name    '
    LabelPosition = lpLeft
    MaxLength = 40
    TabOrder = 9
    OnExit = LbEditControlAutoCapitalExit
    OnKeyDown = LbEditControlAutoCapitalKeyDown
  end
  object LbEMiddle: TLabeledEdit
    Left = 72
    Top = 80
    Width = 401
    Height = 21
    Anchors = [akTop, akRight]
    Color = 10682367
    EditLabel.Width = 61
    EditLabel.Height = 13
    EditLabel.Caption = 'Middle          '
    LabelPosition = lpLeft
    MaxLength = 40
    TabOrder = 10
    OnExit = LbEditControlAutoCapitalExit
    OnKeyDown = LbEditControlAutoCapitalKeyDown
  end
  object DTPDOB: TDateTimePicker
    Left = 72
    Top = 104
    Width = 85
    Height = 21
    Date = 0.430481226852862200
    Format = 'dd/MM/yyyy'
    Time = 0.430481226852862200
    Color = 10682367
    TabOrder = 11
    OnChange = DTPDOBChange
    OnExit = DTPDOBExit
  end
  object LbEAge: TLabeledEdit
    Left = 230
    Top = 104
    Width = 34
    Height = 21
    TabStop = False
    Anchors = [akTop, akRight]
    EditLabel.Width = 19
    EditLabel.Height = 13
    EditLabel.Caption = 'Age'
    LabelPosition = lpLeft
    ReadOnly = True
    TabOrder = 0
  end
  object CmBDentist: TComboBox
    Left = 72
    Top = 128
    Width = 313
    Height = 21
    Style = csDropDownList
    Color = 10682367
    ItemHeight = 13
    ItemIndex = 7
    TabOrder = 12
    OnExit = LbEditControlAutoCapitalExit
    OnKeyDown = LbEditControlAutoCapitalKeyDown
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
  object BtNewProvider: TButton
    Left = 398
    Top = 126
    Width = 75
    Height = 23
    Caption = 'New'
    TabOrder = 1
    TabStop = False
    OnClick = BtNewProviderClick
  end
  object LbEAddr1: TLabeledEdit
    Left = 72
    Top = 152
    Width = 401
    Height = 21
    Anchors = [akTop, akRight]
    Color = 10682367
    EditLabel.Width = 63
    EditLabel.Height = 13
    EditLabel.Caption = ' Addr Line 1  '
    LabelPosition = lpLeft
    MaxLength = 50
    TabOrder = 13
    OnExit = LbEditControlAutoCapitalExit
    OnKeyDown = LbEditControlAutoCapitalKeyDown
  end
  object LbEAddr2: TLabeledEdit
    Left = 72
    Top = 176
    Width = 401
    Height = 21
    Anchors = [akTop, akRight]
    Color = 10682367
    EditLabel.Width = 60
    EditLabel.Height = 13
    EditLabel.Caption = 'Addr Line 2  '
    LabelPosition = lpLeft
    MaxLength = 50
    TabOrder = 14
    OnExit = LbEditControlAutoCapitalExit
    OnKeyDown = LbEditControlAutoCapitalKeyDown
  end
  object LbESuburb: TLabeledEdit
    Left = 72
    Top = 200
    Width = 137
    Height = 21
    Anchors = [akTop, akRight]
    Color = 10682367
    EditLabel.Width = 61
    EditLabel.Height = 13
    EditLabel.Caption = 'Suburb         '
    LabelPosition = lpLeft
    MaxLength = 25
    TabOrder = 15
    OnExit = LbEditControlAutoCapitalExit
    OnKeyDown = LbEditControlAutoCapitalKeyDown
  end
  object LbEPostcode: TLabeledEdit
    Left = 312
    Top = 200
    Width = 65
    Height = 21
    Anchors = [akTop, akRight]
    Color = 10682367
    EditLabel.Width = 54
    EditLabel.Height = 13
    EditLabel.Caption = 'Postcode   '
    LabelPosition = lpLeft
    MaxLength = 6
    TabOrder = 16
  end
  object LbEState: TLabeledEdit
    Left = 424
    Top = 200
    Width = 49
    Height = 21
    Anchors = [akTop, akRight]
    Color = 10682367
    EditLabel.Width = 25
    EditLabel.Height = 13
    EditLabel.Caption = 'State'
    LabelPosition = lpLeft
    MaxLength = 3
    TabOrder = 17
    OnExit = LbEditControlAllCapitalExit
    OnKeyDown = LbEditControlAllCapitalKeyDown
  end
  object LbEPhone1: TLabeledEdit
    Left = 72
    Top = 224
    Width = 160
    Height = 21
    Anchors = [akTop, akRight]
    Color = 10682367
    EditLabel.Width = 61
    EditLabel.Height = 13
    EditLabel.Caption = 'Phone 1       '
    LabelPosition = lpLeft
    MaxLength = 16
    TabOrder = 18
  end
  object LbEPhone2: TLabeledEdit
    Left = 312
    Top = 224
    Width = 160
    Height = 21
    Anchors = [akTop, akRight]
    Color = 10682367
    EditLabel.Width = 55
    EditLabel.Height = 13
    EditLabel.Caption = 'Phone 2     '
    LabelPosition = lpLeft
    MaxLength = 16
    TabOrder = 19
  end
  object CmBMaleTitle: TComboBox
    Left = 72
    Top = 256
    Width = 58
    Height = 21
    Style = csDropDownList
    Color = 10682367
    ItemHeight = 13
    TabOrder = 20
    Visible = False
    OnChange = CmBTitleChange
    Items.Strings = (
      'Master'
      'Mr')
  end
  object CmBFemaleTitle: TComboBox
    Left = 8
    Top = 256
    Width = 58
    Height = 21
    Style = csDropDownList
    Color = 10682367
    ItemHeight = 13
    TabOrder = 21
    Visible = False
    OnChange = CmBTitleChange
    Items.Strings = (
      'Miss'
      'Mrs'
      'Ms')
  end
end
