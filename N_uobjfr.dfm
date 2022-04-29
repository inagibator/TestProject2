object N_UObjFrame: TN_UObjFrame
  Left = 0
  Top = 0
  Width = 131
  Height = 23
  TabOrder = 0
  OnContextPopup = UObjContextPopup
  DesignSize = (
    131
    23)
  object mb: TComboBox
    Left = 11
    Top = 1
    Width = 90
    Height = 21
    AutoComplete = False
    Anchors = [akTop, akRight]
    ItemHeight = 13
    TabOrder = 0
    OnCloseUp = mbCloseUp
    OnContextPopup = UObjContextPopup
    OnKeyDown = mbKeyDown
  end
  object bnBrowse: TButton
    Left = 106
    Top = 1
    Width = 21
    Height = 21
    Anchors = [akTop, akRight]
    Caption = '...'
    TabOrder = 1
    OnClick = bnBrowseClick
  end
  object UObjActList: TActionList
    Images = N_ButtonsForm.ButtonsList
    Left = 40
    Top = 65530
    object aExecuteComp: TAction
      Category = 'View'
      Caption = 'Execute Comp.'
      ImageIndex = 99
      OnExecute = aExecuteCompExecute
    end
    object aViewMain: TAction
      Category = 'View'
      Caption = 'View Component'
      ImageIndex = 33
      OnExecute = aViewMainExecute
    end
    object aViewInfo: TAction
      Category = 'View'
      Caption = 'View Info (+Ctrl - SysInfo)'
      ImageIndex = 31
      OnExecute = aViewInfoExecute
    end
    object aViewFields: TAction
      Category = 'View'
      Caption = 'View Fields'
      ImageIndex = 32
      OnExecute = aViewFieldsExecute
    end
    object aEditFields: TAction
      Category = 'Edit'
      Caption = 'Edit Fields'
      ImageIndex = 108
      OnExecute = aEditFieldsExecute
    end
    object aEditParams: TAction
      Category = 'Edit'
      Caption = 'Edit ... '
      ImageIndex = 65
      OnExecute = aEditParamsExecute
    end
    object aEditUDRArray: TAction
      Category = 'Edit'
      Caption = 'Edit Data Sys'
      OnExecute = aEditUDRArrayExecute
    end
    object aEditUDVector: TAction
      Category = 'Edit'
      Caption = 'Edit UDVector'
      OnExecute = aEditUDVectorExecute
    end
    object aSpecialEdit1: TAction
      Category = 'Special Editors'
      Caption = 'aSpecialEdit1'
      OnExecute = aSpecialEdit1Execute
    end
    object aSpecialEdit2: TAction
      Category = 'Special Editors'
      Caption = 'aSpecialEdit2'
      OnExecute = aSpecialEdit2Execute
    end
    object aSpecialEdit3: TAction
      Category = 'Special Editors'
      Caption = 'aSpecialEdit3'
      OnExecute = aSpecialEdit3Execute
    end
    object aEdRename: TAction
      Category = 'Edit'
      Caption = 'Rename'
      ImageIndex = 44
      OnExecute = aEdRenameExecute
    end
    object aEdDelete: TAction
      Category = 'Edit'
      Caption = 'Delete'
      ImageIndex = 17
      OnExecute = aEdDeleteExecute
    end
    object aUDMemLoad: TAction
      Category = 'UDMem'
      Caption = 'Load Self from MVFile'
      ImageIndex = 4
      OnExecute = aUDMemLoadExecute
    end
    object aUDMemSave: TAction
      Category = 'UDMem'
      Caption = 'Save Self To MVFile'
      ImageIndex = 5
      OnExecute = aUDMemSaveExecute
    end
    object aUDMemViewAsText: TAction
      Category = 'UDMem'
      Caption = 'View Self As Text or Hex'
      ImageIndex = 162
      OnExecute = aUDMemViewAsTextExecute
    end
    object aArchSecLoad: TAction
      Category = 'ArchSection'
      Caption = 'Load Archive Section'
      ImageIndex = 4
      OnExecute = aArchSecLoadExecute
    end
    object aArchSecSave: TAction
      Category = 'ArchSection'
      Caption = 'Save Archive Section'
      ImageIndex = 5
      OnExecute = aArchSecSaveExecute
    end
    object aArchSecEditParams: TAction
      Category = 'ArchSection'
      Caption = 'Edit Archive Section Params'
      ImageIndex = 134
      OnExecute = aArchSecEditParamsExecute
    end
  end
end
