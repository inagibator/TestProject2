object K_FrameUDList: TK_FrameUDList
  Left = 0
  Top = 0
  Width = 215
  Height = 25
  TabOrder = 0
  DesignSize = (
    215
    25)
  object UDIcon: TImage
    Left = 0
    Top = 3
    Width = 18
    Height = 18
    Visible = False
  end
  object CmB: TComboBox
    Left = 20
    Top = 2
    Width = 169
    Height = 21
    Style = csDropDownList
    Anchors = [akLeft, akTop, akRight]
    ItemHeight = 13
    TabOrder = 0
    OnDblClick = CmBDblClick
    OnKeyDown = CmBKeyDown
    OnSelect = CmBSelect
  end
  object BtTreeSelect: TButton
    Left = 192
    Top = 2
    Width = 21
    Height = 21
    Action = SelectUDObj
    Anchors = [akTop, akRight]
    ParentShowHint = False
    ShowHint = True
    TabOrder = 1
  end
  object ActionList1: TActionList
    Images = N_ButtonsForm.ButtonsList
    Left = 88
    object SelectUDObj: TAction
      Caption = '...'
      Hint = #1042#1099#1073#1088#1072#1090#1100' '#1086#1073#1098#1077#1082#1090' '#1080#1079' '#1076#1077#1088#1077#1074#1072' ...'
      ImageIndex = 45
      OnExecute = SelectUDObjExecute
    end
  end
end
