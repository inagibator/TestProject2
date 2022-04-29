inherited N_CMCaptDev30aForm: TN_CMCaptDev30aForm
  Left = 160
  Top = 627
  BorderIcons = [biSystemMenu, biMinimize]
  Caption = 'Morita'
  ClientHeight = 153
  ClientWidth = 467
  OldCreateOrder = True
  OnShow = FormShow
  ExplicitWidth = 483
  ExplicitHeight = 192
  DesignSize = (
    467
    153)
  PixelsPerInch = 96
  TextHeight = 13
  inherited BFMinBRPanel: TPanel
    Left = 481
    Top = 134
    ExplicitLeft = 481
    ExplicitTop = 134
  end
  object bnOK: TButton
    Left = 408
    Top = 110
    Width = 75
    Height = 26
    Anchors = [akRight, akBottom]
    Caption = 'OK'
    ModalResult = 1
    TabOrder = 1
    TabStop = False
    OnClick = bnOKClick
  end
  inline FileNameFrame: TN_FileNameFrame
    Tag = 161
    Left = 16
    Top = 20
    Width = 421
    Height = 27
    Anchors = [akLeft, akTop, akRight]
    PopupMenu = FileNameFrame.FilePopupMenu
    TabOrder = 2
    ExplicitLeft = 16
    ExplicitTop = 20
    ExplicitWidth = 421
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
      Width = 331
      ExplicitWidth = 331
    end
    inherited bnBrowse_1: TButton
      Left = 397
      ExplicitLeft = 397
    end
  end
  inline OutputNameFrame: TN_FileNameFrame
    Tag = 161
    Left = 16
    Top = 53
    Width = 421
    Height = 27
    Anchors = [akLeft, akTop, akRight]
    PopupMenu = FileNameFrame.FilePopupMenu
    TabOrder = 3
    ExplicitLeft = 16
    ExplicitTop = 53
    ExplicitWidth = 421
    inherited Label1: TLabel
      Left = 3
      Top = 7
      Width = 54
      Caption = 'Output File:'
      ExplicitLeft = 3
      ExplicitTop = 7
      ExplicitWidth = 54
    end
    inherited mbFileName: TComboBox
      Width = 331
      ExplicitWidth = 331
    end
    inherited bnBrowse_1: TButton
      Left = 397
      ExplicitLeft = 397
    end
  end
  object cbDisable: TCheckBox
    Left = 19
    Top = 94
    Width = 198
    Height = 17
    Caption = 'Disable Mediasuite Capture Interface'
    Checked = True
    State = cbChecked
    TabOrder = 4
  end
end
