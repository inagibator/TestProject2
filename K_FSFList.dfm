inherited K_FormSelectFromList: TK_FormSelectFromList
  Left = 349
  Top = 226
  Width = 147
  Height = 92
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSizeToolWin
  Caption = 'K_FormSelectFromList'
  Constraints.MinHeight = 90
  Constraints.MinWidth = 135
  OldCreateOrder = True
  PixelsPerInch = 96
  TextHeight = 13
  inherited BFMinBRPanel: TPanel
    Left = 127
    Top = 46
    TabOrder = 3
  end
  object CheckListBox: TCheckListBox
    Left = 0
    Top = 0
    Width = 139
    Height = 25
    Anchors = [akLeft, akTop, akRight, akBottom]
    ItemHeight = 13
    TabOrder = 0
    OnDblClick = SelectListBoxDblClick
  end
  object BtCancel: TButton
    Left = 71
    Top = 32
    Width = 60
    Height = 21
    Anchors = [akRight, akBottom]
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 1
  end
  object BtOK: TButton
    Left = 7
    Top = 32
    Width = 60
    Height = 21
    Anchors = [akRight, akBottom]
    Caption = 'OK'
    ModalResult = 1
    TabOrder = 2
  end
  object SelectListBox: TListBox
    Left = 0
    Top = 0
    Width = 139
    Height = 25
    Anchors = [akLeft, akTop, akRight, akBottom]
    ItemHeight = 13
    TabOrder = 4
    OnDblClick = SelectListBoxDblClick
  end
end
