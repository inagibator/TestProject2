inherited N_NVTreeFrame: TN_NVTreeFrame
  Width = 173
  Height = 105
  Color = clBtnFace
  inherited TreeView: TTreeView
    Width = 173
    Height = 105
    TabOrder = 1
  end
  inherited EdName: TEdit
    TabOrder = 0
  end
  object NVTreeActionList: TActionList
    Images = N_ButtonsForm.ButtonsList
    Left = 119
    Top = 7
    object aViewEntriesInSubTree: TAction
      Category = 'View'
      Caption = 'View Entries in SubTree '
      ImageIndex = 102
      OnExecute = aViewEntriesInSubTreeExecute
    end
    object aViewRefsToMarked: TAction
      Category = 'View'
      Caption = 'View Refs To Marked UObjects'
      ImageIndex = 105
      OnExecute = aViewRefsToMarkedExecute
    end
    object aViewRefsFromSubTree: TAction
      Category = 'View'
      Caption = 'View Refs From Selected SubTree '
      ImageIndex = 103
      OnExecute = aViewRefsFromSubTreeExecute
    end
    object aViewRefsBetween: TAction
      Category = 'View'
      Caption = 'View Refs From SubTree To SubTree'
      ImageIndex = 104
      OnExecute = aViewRefsBetweenExecute
    end
    object aViewRefreshFrame: TAction
      Category = 'View'
      Caption = 'Refresh Frame'
      Hint = 'Refresh VTree (+Shift - Aliase, +Ctrl - Changed)'
      ImageIndex = 76
      OnExecute = aViewRefreshFrameExecute
    end
    object aViewCloseOwnedForms: TAction
      Category = 'View'
      Caption = 'Close Child Forms'
      ImageIndex = 16
      OnExecute = aViewCloseOwnedFormsExecute
    end
    object aViewMoveUp: TAction
      Category = 'View'
      Caption = 'Move Up'
      Hint = 'Move Selected UObj Up'
      ImageIndex = 93
      OnExecute = aViewMoveUpExecute
    end
    object aViewMoveDown: TAction
      Category = 'View'
      Caption = 'Move Down'
      Hint = 'Move Selected UObj Down'
      ImageIndex = 94
      OnExecute = aViewMoveDownExecute
    end
    object aEdCreateNewUObj: TAction
      Category = 'Edit'
      Caption = 'Create New UObj'
      Hint = 'Create New UObj'
      ImageIndex = 60
      OnExecute = aEdCreateNewUObjExecute
    end
    object aEdCutMarked: TAction
      Category = 'Edit'
      Caption = 'Cut Marked'
      Hint = 'Cut Marked UObjects'
      ImageIndex = 14
      OnExecute = aEdCutMarkedExecute
    end
    object aEdCopyMarked: TAction
      Category = 'Edit'
      Caption = 'Copy Marked'
      Hint = 'Copy Marked UObjects'
      ImageIndex = 12
      OnExecute = aEdCopyMarkedExecute
    end
    object aEdDeleteMarked: TAction
      Category = 'Edit'
      Caption = 'Delete Marked'
      Hint = 'Delete Marked UObjects'
      ImageIndex = 17
      OnExecute = aEdDeleteMarkedExecute
    end
    object aEdEditUObjInfo: TAction
      Category = 'Edit'
      Caption = 'Edit UObj Info'
      Hint = 'Edit UObj Info'
      ImageIndex = 31
      OnExecute = aEdEditUObjInfoExecute
    end
    object aEdPasteRefsBefore: TAction
      Category = 'Edit'
      Caption = 'Paste Refs Before All Marked'
      ImageIndex = 81
      OnExecute = aEdPasteRefsBeforeExecute
    end
    object aEdPasteRefsAfter: TAction
      Category = 'Edit'
      Caption = 'Paste Refs  After  All Marked'
      ImageIndex = 81
      OnExecute = aEdPasteRefsAfterExecute
    end
    object aEdPasteRefsInside: TAction
      Category = 'Edit'
      Caption = 'Paste Refs  Inside All Marked'
      ImageIndex = 81
      OnExecute = aEdPasteRefsInsideExecute
    end
    object aEdPasteRefsInstead: TAction
      Category = 'Edit'
      Caption = 'Paste Refs Instead of All Marked'
      ImageIndex = 81
      OnExecute = aEdPasteRefsInsteadExecute
    end
    object aEdPasteRefsAny: TAction
      Category = 'Edit'
      Caption = 'aEdPasteRefsAny'
      Hint = 
        'Paste Referencies Before (+Shift - Inside, +Ctrl - After, +Shift' +
        '+Ctrl - Instead of) All Marked'
      ImageIndex = 81
      OnExecute = aEdPasteRefsAnyExecute
    end
    object aFileLoadBefore: TAction
      Category = 'File'
      Caption = 'Load Before All Marked'
      OnExecute = aFileLoadBeforeExecute
    end
    object aFileLoadInside: TAction
      Category = 'File'
      Caption = 'Load  Inside All Marked'
      OnExecute = aFileLoadInsideExecute
    end
    object aFileLoadInstead: TAction
      Category = 'File'
      Caption = 'Load Instead of All Marked'
      OnExecute = aFileLoadInsteadExecute
    end
    object aFileLoadFields: TAction
      Category = 'File'
      Caption = 'Load Fields of Selected'
      OnExecute = aFileLoadFieldsExecute
    end
    object aFileSaveUObjects: TAction
      Category = 'File'
      Caption = 'Save Marked'
      OnExecute = aFileSaveUObjectsExecute
    end
    object aFileSaveFields: TAction
      Category = 'File'
      Caption = 'Save Fields of Selected'
      OnExecute = aFileSaveFieldsExecute
    end
    object aOtherAlign: TAction
      Category = 'Other'
      Caption = 'Align Components'
      Hint = 'Align, Move, Resize Components ...'
      ImageIndex = 92
      OnExecute = aOtherAlignExecute
    end
    object aOtherExportComp: TAction
      Category = 'Other'
      Caption = 'Export Component'
      Hint = 'Export Component ...'
      ImageIndex = 5
      OnExecute = aOtherExportCompExecute
    end
    object aEdPasteOLCBefore: TAction
      Category = 'Edit'
      Caption = 'Paste OneLevel Clones Before All Marked'
      ImageIndex = 80
      OnExecute = aEdPasteOLCBeforeExecute
    end
    object aEdPasteOLCAfter: TAction
      Category = 'Edit'
      Caption = 'Paste OneLevel Clones  After  All Marked'
      ImageIndex = 80
      OnExecute = aEdPasteOLCAfterExecute
    end
    object aEdPasteOLCInside: TAction
      Category = 'Edit'
      Caption = 'Paste OneLevel Clones  Inside All Marked'
      ImageIndex = 80
      OnExecute = aEdPasteOLCInsideExecute
    end
    object aEdPasteOLCInstead: TAction
      Category = 'Edit'
      Caption = 'Paste OneLevel Clones Instead of All Marked'
      ImageIndex = 80
      OnExecute = aEdPasteOLCInsteadExecute
    end
    object aEdPasteOLCAny: TAction
      Category = 'Edit'
      Caption = 'Paste OneLevel Clones'
      Hint = 
        'Paste OneLevel Clones Before (+Shift - Inside, +Ctrl - After, +S' +
        'hift+Ctrl - Instead of) All Marked'
      ImageIndex = 80
      OnExecute = aEdPasteOLCAnyExecute
    end
    object aEdPasteSubTreesBefore: TAction
      Category = 'Edit'
      Caption = 'Paste SubTree Clones Before All Marekd'
      ImageIndex = 82
      OnExecute = aEdPasteSubTreesBeforeExecute
    end
    object aEdPasteSubTreesAfter: TAction
      Category = 'Edit'
      Caption = 'Paste SubTree Clones  After  All Marekd'
      ImageIndex = 82
      OnExecute = aEdPasteSubTreesAfterExecute
    end
    object aEdPasteSubTreesInside: TAction
      Category = 'Edit'
      Caption = 'Paste SubTree Clones  Inside All Marked'
      ImageIndex = 82
      OnExecute = aEdPasteSubTreesInsideExecute
    end
    object aEdPasteSubTreesInstead: TAction
      Category = 'Edit'
      Caption = 'Paste SubTree Clones Instead of All Marked'
      ImageIndex = 82
      OnExecute = aEdPasteSubTreesInsteadExecute
    end
    object aEdPasteSubTreesAny: TAction
      Category = 'Edit'
      Caption = 'Paste SubTree Clones'
      Hint = 
        'Paste SubTree Clones Before (+Shift - Inside, +Ctrl - After, +Sh' +
        'ift+Ctrl - Instead of) All Marked'
      ImageIndex = 82
      OnExecute = aEdPasteSubTreesAnyExecute
    end
    object aEdForceSingleOneLevelInstance: TAction
      Category = 'Edit'
      Caption = 'Force Single OneLevel Instance'
      OnExecute = aEdForceSingleOneLevelInstanceExecute
    end
    object aEdForceSingleSubTreeInstance: TAction
      Category = 'Edit'
      Caption = 'Force Single SubTree Instance'
      OnExecute = aEdForceSingleSubTreeInstanceExecute
    end
    object aEdSetVisualOwnersToMarked: TAction
      Category = 'Edit'
      Caption = 'Set Owners in Marked '
      OnExecute = aEdSetVisualOwnersToMarkedExecute
    end
    object aOtherSetMarkedCSCodes: TAction
      Category = 'Other'
      Caption = 'Set CS Codes in Marked SubTrees'
      OnExecute = aOtherSetMarkedCSCodesExecute
    end
    object aDebViewMarked: TAction
      Category = 'Deb1'
      Caption = 'View Marked UObjects'
      OnExecute = aDebViewMarkedExecute
    end
    object aDebViewClipboard: TAction
      Category = 'Deb1'
      Caption = 'View UObjects in Clipboard'
      OnExecute = aDebViewClipboardExecute
    end
    object aOtherSetMarkedObjNames: TAction
      Category = 'Other'
      Caption = 'Set New Names of Marked'
      OnExecute = aOtherSetMarkedObjNamesExecute
    end
    object aDebViewRefsToMarked: TAction
      Category = 'Deb1'
      Caption = 'View All Refs To Marked UObjects'
      OnExecute = aDebViewRefsToMarkedExecute
    end
    object aDebViewTwoExtRefsLists: TAction
      Category = 'Deb1'
      Caption = 'View External Refs in Marked SubTrees'
      OnExecute = aDebViewTwoExtRefsListsExecute
    end
    object aDebViewRefsInSelected: TAction
      Category = 'Deb1'
      Caption = 'View All Refs in Selected SubTree'
      OnExecute = aDebViewRefsInSelectedExecute
    end
    object aDebCheckArchConsistency: TAction
      Category = 'Deb1'
      Caption = 'Check Archive Consistency'
      OnExecute = aDebCheckArchConsistencyExecute
    end
    object aDebCheckProject: TAction
      Category = 'Deb1'
      Caption = 'Check Project Consistency'
      Hint = 'Check Project Consistency'
      OnExecute = aDebCheckProjectExecute
    end
    object aDebViewCompCoords: TAction
      Category = 'Deb1'
      Caption = 'View Comp. Coords'
      OnExecute = aDebViewCompCoordsExecute
    end
    object aOtherMarkChildren: TAction
      Category = 'Other'
      Caption = 'Mark Children of Marked UObjects'
      Hint = 'Mark Children of Marked UObjects'
      ImageIndex = 5
      OnExecute = aOtherMarkChildrenExecute
    end
    object aOtherShowOptionsForm: TAction
      Category = 'Other'
      Caption = 'Edit Options ...'
      Hint = 'Edit Options ...'
      ImageIndex = 19
      OnExecute = aOtherShowOptionsFormExecute
    end
    object aDebTmpAction1: TAction
      Category = 'Deb1'
      Caption = 'Tmp Action1'
      ImageIndex = 95
      OnExecute = aDebTmpAction1Execute
    end
    object aDebTmpAction2: TAction
      Category = 'Deb1'
      Caption = 'Tmp Action2'
      ImageIndex = 96
      OnExecute = aDebTmpAction2Execute
    end
    object aDebTmpAction3: TAction
      Category = 'Deb1'
      Caption = 'Tmp Action3'
      ImageIndex = 97
      OnExecute = aDebTmpAction3Execute
    end
    object aNoOnClickAction: TAction
      Category = 'Other'
      Caption = 'aNoOnClickAction'
      ImageIndex = 16
    end
    object aOtherShowStatistics: TAction
      Category = 'Other'
      Caption = 'Show Statistics about Marked'
      ImageIndex = 30
      OnExecute = aOtherShowStatisticsExecute
    end
    object aEdClearUObjWasChangedBit: TAction
      Category = 'Edit'
      Caption = 'Clear UObjWasChanged Bit'
      ImageIndex = 70
      OnExecute = aEdClearUObjWasChangedBitExecute
    end
    object aEdUnresolveRefsInSelected: TAction
      Category = 'Edit'
      Caption = 'Unresolve Refs In Selected SubTree'
      ImageIndex = 73
      OnExecute = aEdUnresolveRefsInSelectedExecute
    end
    object aEdResolveRefsInSelected: TAction
      Category = 'Edit'
      Caption = 'Resolve Refs In Selected SubTree'
      ImageIndex = 72
      OnExecute = aEdResolveRefsInSelectedExecute
    end
    object aEdClearUnresolvedRefs: TAction
      Category = 'Edit'
      Caption = 'Clear Unresolved Refs in Selected SubTree'
      ImageIndex = 16
      OnExecute = aEdClearUnresolvedRefsExecute
    end
    object aFileEditArchSectionParams: TAction
      Category = 'File'
      Caption = 'Edit Archive Section Params'
      OnExecute = aFileEditArchSectionParamsExecute
    end
    object aFileLoadArchSections: TAction
      Category = 'File'
      Caption = 'Load Marked Archive Sections'
      OnExecute = aFileLoadArchSectionsExecute
    end
    object aDeb2RunWMacro: TAction
      Category = 'Deb2'
      Caption = 'Run Word Macro'
      ImageIndex = 86
      OnExecute = aDeb2RunWMacroExecute
    end
    object aEdRedirectRefs: TAction
      Category = 'Edit'
      Caption = 'Redirect Refs in SubTree'
      ImageIndex = 92
      OnExecute = aEdRedirectRefsExecute
    end
    object aEdReplaceUObjects: TAction
      Category = 'Edit'
      Caption = 'Replace Marked UObjects'
      ImageIndex = 44
      OnExecute = aEdReplaceUObjectsExecute
    end
    object aSp1ChangeCObjRT: TAction
      Category = 'Spec1'
      Caption = 'Change CObj "Run Time" Flag  ...'
      OnExecute = aSp1ChangeCObjRTExecute
    end
    object aSp1ChangeCompSkip: TAction
      Category = 'Spec1'
      Caption = 'Change Comp. "Skip Exec"  Flag  ...'
      OnExecute = aSp1ChangeCompSkipExecute
    end
    object aSp1ViewClearRAFields: TAction
      Category = 'Spec1'
      Caption = 'View/Clear UDRArray Fields'
      OnExecute = aSp1ViewClearRAFieldsExecute
    end
    object aOtherShowVideoDevs: TAction
      Category = 'Other'
      Caption = 'Show Video Devices List'
      ImageIndex = 108
      OnExecute = aOtherShowVideoDevsExecute
    end
  end
end
