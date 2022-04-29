inherited K_FormCMCacheRecoverMedia: TK_FormCMCacheRecoverMedia
  Left = 495
  Top = 198
  Width = 524
  Height = 453
  BorderIcons = [biSystemMenu, biMaximize]
  Caption = 'Unsaved object(s) recovery'
  OldCreateOrder = True
  PixelsPerInch = 96
  TextHeight = 13
  inherited BFMinBRPanel: TPanel
    Left = 504
    Top = 407
  end
  inline VTreeFrame: TN_VTreeFrame
    Left = 8
    Top = 8
    Width = 310
    Height = 404
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
    inherited TreeView: TTreeView
      Width = 310
      Height = 404
    end
  end
  object BtRecover: TButton
    Left = 348
    Top = 354
    Width = 145
    Height = 25
    Action = aRecoverSelected
    Anchors = [akTop, akRight]
    TabOrder = 2
  end
  object GBCurPatInfo: TGroupBox
    Left = 328
    Top = 240
    Width = 180
    Height = 39
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
    Left = 329
    Top = 4
    Width = 180
    Height = 229
    Anchors = [akTop, akRight]
    Caption = '  Current Media  '
    TabOrder = 4
    DesignSize = (
      180
      229)
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
    object LbMediaClient: TLabel
      Left = 15
      Top = 200
      Width = 29
      Height = 13
      Caption = 'Client:'
      Visible = False
    end
    object LbMediaClientName: TLabel
      Left = 55
      Top = 200
      Width = 54
      Height = 13
      Caption = 'ClientName'
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
      inherited PaintBox: TPaintBox
        Width = 134
        Height = 134
      end
      inherited HScrollBar: TScrollBar
        Top = 134
        Width = 150
      end
      inherited VScrollBar: TScrollBar
        Left = 134
        Height = 134
      end
    end
  end
  object BtCancel: TButton
    Left = 348
    Top = 387
    Width = 145
    Height = 25
    Anchors = [akTop, akRight]
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 5
  end
  object RGSortOrder: TRadioGroup
    Left = 328
    Top = 283
    Width = 180
    Height = 57
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
