inherited N_CMCaptDev28aForm: TN_CMCaptDev28aForm
  Left = 160
  Top = 627
  BorderIcons = [biSystemMenu, biMinimize]
  Caption = 'RayScan'
  ClientHeight = 114
  ClientWidth = 469
  OldCreateOrder = True
  OnShow = FormShow
  ExplicitWidth = 485
  ExplicitHeight = 153
  DesignSize = (
    469
    114)
  PixelsPerInch = 96
  TextHeight = 13
  inherited BFMinBRPanel: TPanel
    Left = 483
    Top = 95
    ExplicitLeft = 483
    ExplicitTop = 95
  end
  object bnOK: TButton
    Left = 410
    Top = 71
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
    Width = 423
    Height = 27
    Anchors = [akLeft, akTop, akRight]
    PopupMenu = FileNameFrame.FilePopupMenu
    TabOrder = 2
    ExplicitLeft = 16
    ExplicitTop = 20
    ExplicitWidth = 423
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
      Width = 333
      ExplicitWidth = 333
    end
    inherited bnBrowse_1: TButton
      Left = 399
      ExplicitLeft = 399
    end
  end
end
