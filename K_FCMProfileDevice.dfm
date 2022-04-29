inherited K_FormCMProfileDevice: TK_FormCMProfileDevice
  Left = 199
  Top = 502
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'Device  Profile'
  ClientHeight = 248
  ClientWidth = 370
  OldCreateOrder = True
  OnCloseQuery = FormCloseQuery
  OnShow = FormShow
  DesignSize = (
    370
    248)
  PixelsPerInch = 96
  TextHeight = 13
  object LbPofileName: TLabel [0]
    Left = 16
    Top = 16
    Width = 60
    Height = 13
    Caption = '&Profile Name'
    FocusControl = EdProfileName
  end
  object LbDevice: TLabel [1]
    Left = 16
    Top = 41
    Width = 34
    Height = 13
    Caption = '&Device'
    FocusControl = CmBDevices
  end
  object LbMediaType: TLabel [2]
    Left = 16
    Top = 69
    Width = 74
    Height = 13
    Caption = '&Media Category'
    FocusControl = CmBMediaTypes
  end
  inherited BFMinBRPanel: TPanel
    Left = 360
    Top = 238
    TabOrder = 7
  end
  object EdProfileName: TEdit
    Left = 104
    Top = 12
    Width = 250
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    Color = 10682367
    TabOrder = 0
    OnExit = EdProfileNameExit
    OnKeyDown = EdProfileNameKeyDown
  end
  object CmBDevices: TComboBox
    Left = 104
    Top = 40
    Width = 250
    Height = 21
    Style = csDropDownList
    Anchors = [akLeft, akTop, akRight]
    Color = 10682367
    DropDownCount = 20
    ItemHeight = 13
    TabOrder = 1
    OnChange = CmBDevicesChange
  end
  object GBIconShortCut: TGroupBox
    Left = 17
    Top = 98
    Width = 340
    Height = 105
    Anchors = [akLeft, akTop, akRight]
    Caption = '  Icon and Shortcut  '
    TabOrder = 2
    object LbToolbarIcon: TLabel
      Left = 50
      Top = 24
      Width = 60
      Height = 13
      Caption = '&Toolbar Icon'
      FocusControl = BtChangeIcon
    end
    object LbShortcut: TLabel
      Left = 50
      Top = 75
      Width = 88
      Height = 13
      Caption = '&Keyboard Shortcut'
      FocusControl = CmBShortcuts
    end
    object IconImage: TImage
      Left = 148
      Top = 14
      Width = 44
      Height = 44
    end
    object BtChangeIcon: TButton
      Left = 211
      Top = 24
      Width = 104
      Height = 23
      Caption = 'Change &Icon ...'
      TabOrder = 0
      OnClick = ChangeIconExecute
    end
    object CmBShortcuts: TComboBox
      Left = 193
      Top = 72
      Width = 95
      Height = 21
      Color = 10682367
      ItemHeight = 13
      TabOrder = 1
      Text = 'None'
    end
  end
  object BtCancel: TButton
    Left = 293
    Top = 214
    Width = 65
    Height = 23
    Anchors = [akRight, akBottom]
    Caption = '&Cancel'
    ModalResult = 2
    TabOrder = 3
  end
  object BtOK: TButton
    Left = 224
    Top = 214
    Width = 65
    Height = 23
    Anchors = [akRight, akBottom]
    Caption = '&OK'
    ModalResult = 1
    TabOrder = 4
  end
  object BtAuto: TButton
    Left = 16
    Top = 214
    Width = 116
    Height = 23
    Anchors = [akLeft, akBottom]
    Caption = '&Auto Processing ...'
    TabOrder = 5
    OnClick = BtAutoClick
  end
  object BtSet: TButton
    Left = 138
    Top = 214
    Width = 75
    Height = 23
    Anchors = [akLeft, akBottom]
    Caption = 'Settings ...'
    TabOrder = 6
    OnClick = BtSetClick
  end
  object CmBMediaTypes: TComboBox
    Left = 104
    Top = 68
    Width = 250
    Height = 21
    Style = csDropDownList
    Anchors = [akLeft, akTop, akRight]
    Color = 10682367
    ItemHeight = 13
    TabOrder = 8
  end
end
