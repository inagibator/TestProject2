inherited K_FormCMSelectLoc: TK_FormCMSelectLoc
  Left = 610
  Top = 453
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'Host location change'
  ClientHeight = 110
  ClientWidth = 228
  PixelsPerInch = 96
  TextHeight = 13
  object LbComments: TLabel [0]
    Left = 15
    Top = 17
    Width = 206
    Height = 24
    Alignment = taCenter
    Anchors = [akLeft, akTop, akRight]
    AutoSize = False
    Caption = 'Please select new host location'
    WordWrap = True
  end
  object LbLoc: TLabel [1]
    Left = 8
    Top = 46
    Width = 44
    Height = 13
    Caption = 'Location:'
  end
  inherited BFMinBRPanel: TPanel
    Left = 218
    Top = 100
    TabOrder = 3
  end
  object BtCancel: TButton
    Left = 156
    Top = 82
    Width = 65
    Height = 23
    Anchors = [akRight, akBottom]
    Caption = '&Cancel'
    ModalResult = 2
    TabOrder = 0
  end
  object BtOK: TButton
    Left = 79
    Top = 82
    Width = 65
    Height = 23
    Anchors = [akRight, akBottom]
    Caption = '&OK'
    ModalResult = 1
    TabOrder = 1
  end
  object CmBLocList: TComboBox
    Left = 58
    Top = 44
    Width = 161
    Height = 21
    Style = csDropDownList
    ItemHeight = 13
    TabOrder = 2
  end
end
