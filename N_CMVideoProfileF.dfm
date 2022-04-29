inherited N_CMVideoProfileForm: TN_CMVideoProfileForm
  Left = 378
  Top = 600
  Caption = 'Video Device Profile'
  ClientHeight = 346
  PixelsPerInch = 96
  TextHeight = 13
  object lbCaptButSupport: TLabel [2]
    Left = 16
    Top = 99
    Width = 108
    Height = 13
    Anchors = [akLeft, akBottom]
    Caption = 'Capture button support'
  end
  object lbDentUnitSupport: TLabel [4]
    Left = 16
    Top = 127
    Width = 91
    Height = 13
    Anchors = [akLeft, akBottom]
    Caption = 'Dental Unit support'
  end
  inherited BtAuto: TButton [5]
    Left = 161
    Top = 271
    Enabled = False
    Visible = False
    ExplicitLeft = 161
    ExplicitTop = 271
  end
  inherited EdProfileName: TEdit
    Width = 249
    ExplicitWidth = 249
  end
  inherited CmBDevices: TComboBox
    Left = 103
    Top = 41
    Width = 249
    ExplicitLeft = 103
    ExplicitTop = 41
    ExplicitWidth = 249
  end
  inherited GBIconShortCut: TGroupBox
    Top = 150
    Anchors = [akLeft, akRight, akBottom]
    ExplicitTop = 150
  end
  inherited BtCancel: TButton
    Left = 290
    Top = 312
    ExplicitLeft = 290
    ExplicitTop = 312
  end
  inherited BtOK: TButton
    Left = 221
    Top = 312
    ExplicitLeft = 221
    ExplicitTop = 312
  end
  inherited BFMinBRPanel: TPanel [11]
    Top = 336
    TabOrder = 10
    ExplicitTop = 336
  end
  inherited BtSet: TButton
    Left = 282
    Top = 272
    ExplicitLeft = 282
    ExplicitTop = 272
  end
  inherited CmBMediaTypes: TComboBox
    Left = 103
    TabOrder = 11
    ExplicitLeft = 103
  end
  object bnCameraProp: TButton
    Left = 16
    Top = 312
    Width = 102
    Height = 23
    Anchors = [akRight, akBottom]
    Caption = 'Camera Properties'
    TabOrder = 7
    OnClick = bnCameraPropClick
  end
  object bnVideoFormat: TButton
    Left = 127
    Top = 312
    Width = 85
    Height = 23
    Anchors = [akRight, akBottom]
    Caption = 'Capture Format'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    TabOrder = 8
    OnClick = bnVideoFormatClick
  end
  object cbCaptButDLL: TComboBox
    Left = 135
    Top = 95
    Width = 218
    Height = 21
    Style = csDropDownList
    Anchors = [akLeft, akBottom]
    Color = 10682367
    DropDownCount = 10
    TabOrder = 9
    OnChange = CmBCameraButtonChange
  end
  object BtPreviewPin: TButton
    Left = 17
    Top = 280
    Width = 101
    Height = 25
    Caption = 'Preview Format'
    TabOrder = 12
    OnClick = BtPreviewPinClick
  end
  object BtStillPin: TButton
    Left = 127
    Top = 281
    Width = 85
    Height = 25
    Caption = 'Still Format'
    TabOrder = 13
    OnClick = BtStillPinClick
  end
  object cbDentUnitDLL: TComboBox
    Left = 135
    Top = 123
    Width = 218
    Height = 21
    Style = csDropDownList
    Anchors = [akLeft, akBottom]
    Color = 10682367
    TabOrder = 14
    OnChange = CmBDentUnitChange
  end
end
