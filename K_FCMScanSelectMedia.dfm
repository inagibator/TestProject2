inherited K_FormCMScanSelectMedia: TK_FormCMScanSelectMedia
  Left = 85
  Top = 198
  BorderIcons = [biSystemMenu, biMaximize]
  Caption = 'Objects recovery'
  ClientHeight = 486
  ClientWidth = 506
  OldCreateOrder = True
  ExplicitWidth = 522
  ExplicitHeight = 525
  PixelsPerInch = 96
  TextHeight = 13
  object LbSelectWarning: TLabel [0]
    Left = 8
    Top = 482
    Width = 389
    Height = 13
    Anchors = [akLeft, akBottom]
    Caption = 
      'Only images with the same X-Ray parameters and Patient can be re' +
      'stored at a time'
    Visible = False
  end
  inherited BFMinBRPanel: TPanel
    Left = 502
    Top = 479
    ExplicitLeft = 502
    ExplicitTop = 479
  end
  inline VTreeFrame: TN_VTreeFrame
    Left = 8
    Top = 8
    Width = 308
    Height = 476
    Anchors = [akLeft, akTop, akRight, akBottom]
    Color = clWhite
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentColor = False
    ParentFont = False
    TabOrder = 1
    ExplicitLeft = 8
    ExplicitTop = 8
    ExplicitWidth = 308
    ExplicitHeight = 476
    inherited TreeView: TTreeView
      Width = 308
      Height = 476
      ExplicitWidth = 308
      ExplicitHeight = 476
    end
  end
  object BtRecover: TButton
    Left = 346
    Top = 421
    Width = 145
    Height = 21
    Action = aRecoverSelected
    Anchors = [akTop, akRight]
    TabOrder = 2
  end
  object GBCurPatInfo: TGroupBox
    Left = 326
    Top = 224
    Width = 177
    Height = 40
    Anchors = [akTop, akRight]
    Caption = '  Media Suite Patient  '
    TabOrder = 3
    object LbCurPatName: TLabel
      Left = 10
      Top = 16
      Width = 60
      Height = 13
      Caption = 'SMITH John'
    end
  end
  object GBCurMediaInfo: TGroupBox
    Left = 327
    Top = 4
    Width = 180
    Height = 209
    Anchors = [akTop, akRight]
    Caption = '  Current Media  '
    TabOrder = 4
    DesignSize = (
      180
      209)
    object LbMediaPatName: TLabel
      Left = 55
      Top = 184
      Width = 60
      Height = 13
      Caption = 'SMITH John'
      Visible = False
    end
    object LbMediaPat: TLabel
      Left = 15
      Top = 184
      Width = 36
      Height = 13
      Caption = 'Patient:'
      Visible = False
    end
    inline RFrame: TN_Rast1Frame
      Left = 15
      Top = 22
      Width = 150
      Height = 150
      HelpType = htKeyword
      Anchors = [akTop, akRight]
      Constraints.MinHeight = 56
      Constraints.MinWidth = 56
      Color = clBtnFace
      ParentColor = False
      TabOrder = 0
      ExplicitLeft = 15
      ExplicitTop = 22
      ExplicitWidth = 150
      ExplicitHeight = 150
      inherited PaintBox: TPaintBox
        Width = 134
        Height = 134
        ExplicitWidth = 134
        ExplicitHeight = 134
      end
      inherited HScrollBar: TScrollBar
        Top = 134
        Width = 150
        ExplicitTop = 134
        ExplicitWidth = 150
      end
      inherited VScrollBar: TScrollBar
        Left = 134
        Height = 134
        ExplicitLeft = 134
        ExplicitHeight = 134
      end
    end
  end
  object BtCancel: TButton
    Left = 346
    Top = 454
    Width = 145
    Height = 21
    Anchors = [akTop, akRight]
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 5
  end
  object RGSortOrder: TRadioGroup
    Left = 326
    Top = 272
    Width = 177
    Height = 40
    Anchors = [akTop, akRight]
    Caption = '  Sort Order  '
    Columns = 2
    ItemIndex = 0
    Items.Strings = (
      'Date'
      'Patient')
    TabOrder = 6
    OnClick = RGSortOrderClick
  end
  object GBView: TGroupBox
    Left = 326
    Top = 325
    Width = 177
    Height = 89
    Anchors = [akTop, akRight]
    Caption = '  View  '
    TabOrder = 7
    object ChBShowRecovered: TCheckBox
      Left = 16
      Top = 16
      Width = 145
      Height = 17
      Caption = 'Show Recovered'
      TabOrder = 0
      OnClick = ChBShowRecoveredClick
    end
    object RBOnline: TRadioButton
      Left = 16
      Top = 40
      Width = 60
      Height = 17
      Caption = 'Online'
      TabOrder = 1
      OnClick = RBOfflineClick
    end
    object RBOffline: TRadioButton
      Left = 16
      Top = 64
      Width = 60
      Height = 17
      Caption = 'Offline'
      TabOrder = 2
      OnClick = RBOfflineClick
    end
  end
  object PopupMenu: TPopupMenu
    Left = 128
    Top = 284
    object Checkallmarkedobjectsforimport1: TMenuItem
      Action = aCheckAllMarkedObjs
    end
    object Uncheckallmarkedobjects1: TMenuItem
      Action = aUncheckAllMarkedObjs
    end
    object Importcheckedobjects1: TMenuItem
      Action = aRecoverSelected
    end
  end
  object ActionList: TActionList
    Left = 168
    Top = 284
    object aCheckAllMarkedObjs: TAction
      Caption = 'Select media'
      Hint = 'Set all marked media checked state for future transfer'
      OnExecute = aCheckAllMarkedObjsExecute
    end
    object aUncheckAllMarkedObjs: TAction
      Caption = 'Unselect media'
      Hint = 'Clear media selected state to prevent future transfer'
      OnExecute = aUncheckAllMarkedObjsExecute
    end
    object aRecoverSelected: TAction
      Caption = 'Recover selected objects'
      Hint = 'Recover all selected objects to Media Suite'
      OnExecute = aRecoverSelectedExecute
    end
  end
end
