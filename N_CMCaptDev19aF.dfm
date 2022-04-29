inherited N_CMCaptDev19aForm: TN_CMCaptDev19aForm
  Left = 160
  Top = 627
  BorderIcons = [biSystemMenu, biMinimize]
  Caption = 'Vatech'
  ClientHeight = 237
  ClientWidth = 467
  OldCreateOrder = True
  OnShow = FormShow
  ExplicitWidth = 483
  ExplicitHeight = 276
  DesignSize = (
    467
    237)
  PixelsPerInch = 96
  TextHeight = 13
  inherited BFMinBRPanel: TPanel
    Left = 481
    Top = 218
    ExplicitLeft = 481
    ExplicitTop = 195
  end
  object bnOK: TButton
    Left = 408
    Top = 194
    Width = 75
    Height = 26
    Anchors = [akRight, akBottom]
    Caption = 'OK'
    ModalResult = 1
    TabOrder = 1
    TabStop = False
    OnClick = bnOKClick
    ExplicitTop = 171
  end
  inline FileNameFrame: TN_FileNameFrame
    Tag = 161
    Left = 16
    Top = 20
    Width = 443
    Height = 27
    Anchors = [akLeft, akTop, akRight]
    PopupMenu = FileNameFrame.FilePopupMenu
    TabOrder = 2
    ExplicitLeft = 16
    ExplicitTop = 20
    ExplicitWidth = 443
    inherited Label1: TLabel
      Left = 3
      Top = 7
      Width = 59
      Caption = 'Capture File:'
      ExplicitLeft = 3
      ExplicitTop = 7
      ExplicitWidth = 59
    end
    inherited mbFileName: TComboBox
      Width = 353
      ExplicitWidth = 331
    end
    inherited bnBrowse_1: TButton
      Left = 419
      ExplicitLeft = 397
    end
  end
  object RadioGroup1: TRadioGroup
    Left = 19
    Top = 64
    Width = 145
    Height = 57
    Caption = 'Viewer Settings'
    Enabled = False
    ItemIndex = 1
    Items.Strings = (
      'CMS 3D'
      'Ez3D-i')
    TabOrder = 3
    OnClick = RadioGroup1Click
  end
  object cbOpenAfter: TCheckBox
    Left = 19
    Top = 127
    Width = 198
    Height = 17
    Caption = 'Open immediately after capture'
    Checked = True
    State = cbChecked
    TabOrder = 4
  end
  inline ThumbnailFrame: TN_FileNameFrame
    Tag = 161
    Left = 16
    Top = 150
    Width = 443
    Height = 27
    Anchors = [akLeft, akTop, akRight]
    PopupMenu = FileNameFrame.FilePopupMenu
    TabOrder = 5
    ExplicitLeft = 16
    ExplicitTop = 150
    ExplicitWidth = 443
    inherited Label1: TLabel
      Left = 3
      Top = 7
      Width = 52
      Caption = 'Thumbnail:'
      ExplicitLeft = 3
      ExplicitTop = 7
      ExplicitWidth = 52
    end
    inherited mbFileName: TComboBox
      Left = 56
      Width = 361
      ExplicitLeft = 56
      ExplicitWidth = 342
    end
    inherited bnBrowse_1: TButton
      Left = 419
      ExplicitLeft = 397
    end
  end
end
