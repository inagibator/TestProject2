object N_UObj2Frame: TN_UObj2Frame
  Left = 0
  Top = 0
  Width = 212
  Height = 23
  TabOrder = 0
  OnContextPopup = FrameContextPopup
  DesignSize = (
    212
    23)
  object mb: TComboBox
    Left = 1
    Top = 1
    Width = 210
    Height = 21
    Anchors = [akLeft, akTop, akRight, akBottom]
    ItemHeight = 13
    TabOrder = 0
    OnCloseUp = mbCloseUp
    OnContextPopup = FrameContextPopup
    OnDblClick = mbDblClick
    OnKeyDown = mbKeyDown
  end
  object UObj2ActList: TActionList
    Left = 48
    Top = 65532
    object aSelectUObj: TAction
      Caption = 'Select UObj in dialog'
      OnExecute = aSelectUObjExecute
    end
    object aSetToVtree: TAction
      Caption = 'Set UObj To Selected in VTree'
      OnExecute = aSetToVtreeExecute
    end
    object aShowUObjMenu: TAction
      Caption = 'Show UObj Menu'
      OnExecute = aShowUObjMenuExecute
    end
  end
end
