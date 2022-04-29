inherited K_FormCMUndoRedo: TK_FormCMUndoRedo
  Left = 370
  Top = 230
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'Undo / Redo'
  ClientHeight = 350
  ClientWidth = 406
  OldCreateOrder = True
  OnCloseQuery = FormCloseQuery
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel [0]
    Left = 7
    Top = 8
    Width = 45
    Height = 13
    Caption = 'Proposed'
  end
  object Label2: TLabel [1]
    Left = 7
    Top = 175
    Width = 34
    Height = 13
    Caption = 'Current'
  end
  object LbURItems: TLabel [2]
    Left = 203
    Top = 8
    Width = 91
    Height = 13
    Caption = 'Undo / Redo Items'
  end
  inherited BFMinBRPanel: TPanel
    Left = 396
    Top = 340
    TabOrder = 5
  end
  object NewPanel: TPanel
    Left = 6
    Top = 24
    Width = 184
    Height = 144
    Caption = '_NewPanel'
    TabOrder = 0
    inline NewRFrame: TN_Rast1Frame
      Left = 2
      Top = 2
      Width = 180
      Height = 140
      HelpType = htKeyword
      Constraints.MinHeight = 56
      Constraints.MinWidth = 56
      Color = clBtnFace
      ParentColor = False
      TabOrder = 0
      inherited PaintBox: TPaintBox
        Width = 164
        Height = 124
      end
      inherited HScrollBar: TScrollBar
        Top = 124
        Width = 180
      end
      inherited VScrollBar: TScrollBar
        Left = 164
        Height = 124
      end
    end
  end
  object OldPanel: TPanel
    Left = 6
    Top = 191
    Width = 184
    Height = 144
    Caption = '_NewPanel'
    TabOrder = 1
    inline OldRFrame: TN_Rast1Frame
      Left = 1
      Top = 1
      Width = 180
      Height = 140
      HelpType = htKeyword
      Constraints.MinHeight = 56
      Constraints.MinWidth = 56
      Color = clBtnFace
      ParentColor = False
      TabOrder = 0
      inherited PaintBox: TPaintBox
        Width = 164
        Height = 124
      end
      inherited HScrollBar: TScrollBar
        Top = 124
        Width = 180
      end
      inherited VScrollBar: TScrollBar
        Left = 164
        Height = 124
      end
    end
  end
  object BtCancel: TButton
    Left = 307
    Top = 315
    Width = 60
    Height = 21
    Anchors = [akRight, akBottom]
    Caption = '&Cancel'
    ModalResult = 2
    TabOrder = 2
  end
  object BtOK: TButton
    Left = 235
    Top = 315
    Width = 60
    Height = 21
    Anchors = [akRight, akBottom]
    Caption = '&OK'
    ModalResult = 1
    TabOrder = 3
  end
  object LVURItems: TListView
    Left = 201
    Top = 24
    Width = 193
    Height = 275
    Anchors = [akLeft, akTop, akRight, akBottom]
    Color = 10682367
    Columns = <
      item
        AutoSize = True
        Caption = 'A'
      end>
    ReadOnly = True
    RowSelect = True
    ShowColumnHeaders = False
    TabOrder = 4
    ViewStyle = vsReport
    OnChange = LVURItemChange
    OnDblClick = LVURItemsDblClick
    OnKeyDown = LVURItemsKeyDown
  end
end
