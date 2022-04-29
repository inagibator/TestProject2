object K_FrameCDCor: TK_FrameCDCor
  Left = 0
  Top = 0
  Width = 886
  Height = 185
  TabOrder = 0
  DesignSize = (
    886
    185)
  inline K_FrameRAEditSec: TK_FrameRAEdit
    Left = 0
    Top = 0
    Width = 300
    Height = 186
    Anchors = [akLeft, akTop, akBottom]
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    ParentShowHint = False
    ShowHint = True
    TabOrder = 0
    inherited SGrid: TStringGrid
      Width = 300
      Height = 186
    end
    inherited BtExtEditor: TButton
      Left = 136
      Top = 8
    end
  end
  object BBtnAdd: TBitBtn
    Left = 305
    Top = 23
    Width = 25
    Height = 25
    Action = AddItems
    Caption = '>'
    ParentShowHint = False
    ShowHint = True
    TabOrder = 1
  end
  object BBtnDel: TBitBtn
    Left = 305
    Top = 51
    Width = 25
    Height = 25
    Action = DelItems
    Caption = 'X<'
    ParentShowHint = False
    ShowHint = True
    TabOrder = 2
  end
  inline K_FrameRAEditPrim: TK_FrameRAEdit
    Left = 335
    Top = 0
    Width = 550
    Height = 187
    Anchors = [akLeft, akTop, akRight, akBottom]
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    ParentShowHint = False
    ShowHint = True
    TabOrder = 3
    inherited SGrid: TStringGrid
      Width = 550
      Height = 187
    end
  end
  object BBtAddAll: TBitBtn
    Left = 305
    Top = 80
    Width = 25
    Height = 25
    Action = AddAllItems
    Caption = '>>'
    ParentShowHint = False
    ShowHint = True
    TabOrder = 4
  end
  object BBtDelAll: TBitBtn
    Left = 305
    Top = 109
    Width = 25
    Height = 25
    Action = DelAllItems
    Caption = 'X<<'
    ParentShowHint = False
    ShowHint = True
    TabOrder = 5
  end
  object ActionList1: TActionList
    Left = 305
    Top = 154
    object AddItems: TAction
      Caption = #1044#1086#1073#1072#1074#1080#1090#1100' '#1101#1076#1077#1084#1077#1085#1090#1099
      Hint = #1044#1086#1073#1072#1074#1080#1090#1100' '#1101#1076#1077#1084#1077#1085#1090#1099
      OnExecute = AddItemsExecute
    end
    object DelItems: TAction
      Caption = #1059#1076#1072#1083#1080#1090#1100' '#1101#1083#1077#1084#1077#1085#1090#1099
      Hint = #1059#1076#1072#1083#1080#1090#1100' '#1101#1083#1077#1084#1077#1085#1090#1099
      OnExecute = DelItemsExecute
    end
    object AddAllItems: TAction
      Caption = #1044#1086#1073#1072#1074#1080#1090#1100' '#1074#1089#1077' '#1101#1083#1077#1084#1077#1085#1090#1099
      Hint = #1044#1086#1073#1072#1074#1080#1090#1100' '#1074#1089#1077' '#1101#1083#1077#1084#1077#1085#1090#1099
      OnExecute = AddAllItemsExecute
    end
    object DelAllItems: TAction
      Caption = #1059#1076#1072#1083#1080#1090#1100' '#1074#1089#1077' '#1101#1083#1077#1084#1077#1085#1090#1099
      Hint = #1059#1076#1072#1083#1080#1090#1100' '#1074#1089#1077' '#1101#1083#1077#1084#1077#1085#1090#1099
      OnExecute = DelAllItemsExecute
    end
  end
end
