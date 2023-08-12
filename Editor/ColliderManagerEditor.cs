/* 
 * Copyright (C) 2021 Victor Soupday
 * This file is part of CC_Unity_Tools <https://github.com/soupday/CC_Unity_Tools>
 * 
 * CC_Unity_Tools is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * 
 * CC_Unity_Tools is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with CC_Unity_Tools.  If not, see <https://www.gnu.org/licenses/>.
 */

using UnityEngine;
using UnityEditor;
using ColliderSettings = Reallusion.Import.ColliderManager.ColliderSettings;
using System.Linq;
using System.Collections.Generic;
using System;
using Object = UnityEngine.Object;
using System.Collections;

namespace Reallusion.Import
{
	[CustomEditor(typeof(ColliderManager))]
	public class ColliderManagerEditor : Editor
	{
        private bool locked = false;
		private bool drawAllGizmos = true;
		private bool processAfterGUI = false;
		private Styles colliderManagerStyles;

        private ColliderManager colliderManager;
		private ColliderSettings currentCollider;
		private bool symmetrical = true;

		const float LABEL_WIDTH = 80f;
		const float GUTTER = 40f;
		const float BUTTON_WIDTH = 160f;

		public static string CURRENT_COLLIDER_NAME
		{
			get
			{
				if (EditorPrefs.HasKey("RL_Current_Collider_Name"))
					return EditorPrefs.GetString("RL_Current_Collider_Name");
				return "";
			}

			set
			{
				EditorPrefs.SetString("RL_Current_Collider_Name", value);
			}
		}

		private void OnEnable()
		{
			colliderManager = (ColliderManager)target;
			InitCurrentCollider(CURRENT_COLLIDER_NAME);
			InitAbstractColliders();

        }

		private void InitCurrentCollider(string name = null)
        {
            currentCollider = null;

			if (colliderManager.settings.Length > 0)
            {
                if (!string.IsNullOrEmpty(name))
				{
					foreach (ColliderSettings cs in colliderManager.settings)
					{
						if (cs.name == name)
						{
							currentCollider = cs;
							return;
						}
					}					
				}

				currentCollider = colliderManager.settings[0];				
			}
		}

		private void InitAbstractColliders()
		{
			colliderManager.abstractedCapsuleColliders = new List<ColliderManager.AbstractCapsuleCollider>();
            //colliderManager.abstractedCapsuleCollidersRef = new List<ColliderManager.AbstractCapsuleCollider>();
            // transpose all of the collider data into the abstract class

            // basic magica test
            Type clothType = Physics.GetTypeInAssemblies("MagicaCloth2.MagicaCloth");
            if (clothType != null)
			{
				//Magica cloth 2 is available
			}
			// determine which type of collliders we are using

            // currently just use native capsules on the target -  this allows for a typeof(magicaCollider) as input
            Type colliderComponentType = typeof(CapsuleCollider);

            colliderManager.genericColliderList = (IList)Physics.CreateGeneric(typeof(List<>), colliderComponentType);

            Transform[] allChildObjects = colliderManager.gameObject.GetComponentsInChildren<Transform>();
			foreach (Transform childObject in allChildObjects)
			{
				GameObject go = childObject.gameObject;
				if (go.GetComponent(colliderComponentType))
				{
					colliderManager.genericColliderList.Add(go.GetComponent(colliderComponentType));
                }
            }
            //Debug.Log("Capsule Count: " + capsules.Length + " Components Count: " + colliderList.Count);            
            foreach (var collider in colliderManager.genericColliderList)
			{
				Transform t = null;
				float height = 0f;
				float radius = 0f;
				string name = "";

                if (Physics.GetTypeProperty(collider, "transform", out object _t))
                    t = (Transform)_t;

                if (Physics.GetTypeProperty(collider, "height", out object _height))
                    height = (float)_height;

				if (Physics.GetTypeProperty(collider, "radius", out object _radius))
					radius = (float)_radius;

				if (Physics.GetTypeProperty(collider, "name", out object _name))
					name = (string)_name;

				colliderManager.abstractedCapsuleColliders.Add(new ColliderManager.AbstractCapsuleCollider(t, t.position, t.rotation, height, radius, name));
                //colliderManager.abstractedCapsuleCollidersRef.Add(new ColliderManager.AbstractCapsuleCollider(t, height, radius, name));

                //Debug.Log("Adding Collider: " + name);
            }
            //colliderManager.abstractedCapsuleCollidersRef = colliderManager.abstractedCapsuleColliders.ToList();  //store a reference copy of the list for reset data
        }

		public class Styles
		{
            public GUIStyle sceneLabelText;
            public GUIStyle objectLabelText;
			public GUIStyle normalButton;
            public GUIStyle currentButton;

            public Styles()
            {
                sceneLabelText = new GUIStyle();
                sceneLabelText.normal.textColor = Color.cyan;
                sceneLabelText.fontSize = 18;

                objectLabelText = new GUIStyle();
                objectLabelText.normal.textColor = Color.red;
                objectLabelText.fontSize = 12;

                normalButton = new GUIStyle(GUI.skin.button);
                currentButton = new GUIStyle(GUI.skin.button);
                currentButton.normal.background = TextureColor(new Color(0.3f, 0.3f, 0.63f, 0.5f));
            }
        }

        private void OnSceneGUI()
        {
			if (colliderManagerStyles == null) colliderManagerStyles = new Styles();

            if (colliderManager.abstractedCapsuleColliders != null)
            {
                foreach (ColliderManager.AbstractCapsuleCollider c in colliderManager.abstractedCapsuleColliders)
                {
                    Color drawCol = c == colliderManager.selectedAbstractCapsuleCollider ? Color.red : new Color(0.60f, 0.9f, 0.60f);
                    if (colliderManager.selectedAbstractCapsuleCollider == c)
                    {
						//large fixed text on the scene view 
                        Handles.BeginGUI();
                        string lockString = ActiveEditorTracker.sharedTracker.isLocked ? "Locked" : "Unlocked";
                        string modeString = colliderManager.manipulatorArray[(int)colliderManager.manipulator];
                        string displayString = "Inspector Status: " + lockString + "\nSelected Collider: " + c.name + "\nMode: " + modeString;                        
                        
                        GUI.Label(new Rect(55, 7, 1000, 1000), displayString, colliderManagerStyles.sceneLabelText);
                        Handles.EndGUI();

						//small floating annotation near the collider                        
                        Handles.Label(c.transform.position + Vector3.up * 0.1f + Vector3.left * 0.1f, c.name, colliderManagerStyles.objectLabelText);
                        
                        DrawWireCapsule(c.transform.position, c.transform.rotation, c.radius, c.height, drawCol);
                        switch (colliderManager.manipulator)
                        {
                            case ColliderManager.ManipulatorType.position:
                                {
                                    Vector3 targetPosition = c.transform.position;									
                                    EditorGUI.BeginChangeCheck();
                                    targetPosition = Handles.PositionHandle(targetPosition, c.transform.rotation);
                                    if (EditorGUI.EndChangeCheck())
                                    {
                                        if (colliderManager.mirrorImageAbstractCapsuleCollider != null)
                                        {
											//Vector3 diff = targetPosition - c.transform.position;
											Vector3 delta = c.transform.parent.InverseTransformPoint(targetPosition) - c.transform.parent.InverseTransformPoint(c.transform.position);
											Quaternion inv = Quaternion.Inverse(c.transform.localRotation);
                                            Vector3 diff = inv * delta;
                                            colliderManager.UpdateColliderFromAbstract(diff, Quaternion.identity);
										}
                                        c.transform.position = targetPosition;
                                    }
                                    break;
                                }
                            case ColliderManager.ManipulatorType.rotation:
                                {
                                    Quaternion targetRotation = c.transform.rotation;
									Quaternion currentLocalRotation = c.transform.localRotation;
                                    EditorGUI.BeginChangeCheck();
                                    targetRotation = Handles.RotationHandle(targetRotation, c.transform.position);									
                                    if (EditorGUI.EndChangeCheck())
                                    {
										Quaternion targetLocalRotation = Quaternion.Inverse(c.transform.parent.rotation) * targetRotation;																				
										if (colliderManager.mirrorImageAbstractCapsuleCollider != null)
                                        {
                                            Vector3 rDiff = targetLocalRotation.eulerAngles - currentLocalRotation.eulerAngles;                                                                                        
                                            colliderManager.UpdateColliderFromAbstract(Vector3.zero, targetLocalRotation);
                                        }
										c.transform.rotation = targetRotation;
									}
									
									break;
                                }
                            case ColliderManager.ManipulatorType.scale:
                                {
                                    Handles.color = Color.green;
                                    EditorGUI.BeginChangeCheck();
									float h = c.height;
									float r = c.radius;
                                    h = Handles.ScaleValueHandle(h,
                                                                c.transform.position + c.transform.up * h * 0.5f,
                                                                c.transform.rotation * Quaternion.Euler(90, 0, 0),
                                                                0.075f, Handles.DotHandleCap, 1);

                                    Handles.DrawWireArc(c.transform.position,
                                                        c.transform.up,
                                                        -c.transform.right,
                                                        180,
                                                        r);

                                    r = Handles.ScaleValueHandle(r,
                                                                c.transform.position + c.transform.forward * r * 1f,
                                                                c.transform.rotation,
                                                                0.075f, Handles.DotHandleCap, 1);

                                    if (EditorGUI.EndChangeCheck())
                                    {
										c.radius = r;
										c.height = h;
										colliderManager.UpdateColliderFromAbstract(Vector3.zero, Quaternion.identity);
                                    }
                                    break;
                                }
                        }
					}
					else
					{
						if (Selection.objects.Contains(colliderManager.gameObject))
						{
							drawAllGizmos = false;
                            if (colliderManager.mirrorImageAbstractCapsuleCollider == c)
								DrawWireCapsule(c.transform.position, c.transform.rotation, c.radius, c.height, Color.magenta);
                        }
						else
							drawAllGizmos = true;

						if (drawAllGizmos)
						{
							if (colliderManager.mirrorImageAbstractCapsuleCollider == c) drawCol = Color.magenta;
                            DrawWireCapsule(c.transform.position, c.transform.rotation, c.radius, c.height, drawCol);
                        }
					}
                }
            }
        }


        public override void OnInspectorGUI()
		{						
			base.OnInspectorGUI();

			OnColliderInspectorGUI();
		}

		public void OnColliderInspectorGUI()
		{
			if (currentCollider == null) return;

			Color background = GUI.backgroundColor;			

			GUILayout.Space(10f);

			GUILayout.Label("Adjust Colliders", EditorStyles.boldLabel);

			GUILayout.Space(10f);
			
            GUI.backgroundColor = Color.Lerp(background, Color.green, 0.9f);
            GUILayout.BeginVertical(EditorStyles.helpBox);
			GUI.backgroundColor = background;

			// addition of new capsule focus commands

			OnColliderControlGUI();

            // end of addition of new capsule focus commands

            /*
            // custom collider adjuster			
            GUILayout.BeginHorizontal();
			GUILayout.Space(GUTTER);
			GUILayout.Label("Collider", GUILayout.Width(LABEL_WIDTH));
			if (EditorGUILayout.DropdownButton(
				new GUIContent(currentCollider.name),
				FocusType.Passive
				))
			{
				GenericMenu menu = new GenericMenu();
				foreach (ColliderSettings c in colliderManager.settings)
				{
					menu.AddItem(new GUIContent(c.name), c == currentCollider, SelectCurrentCollider, c);
				}
				menu.ShowAsContext();
			}
			GUILayout.EndHorizontal();


			GUILayout.Space(8f);

			EditorGUI.BeginChangeCheck();

			GUILayout.BeginHorizontal();
			GUILayout.Space(GUTTER);
			GUILayout.Label("Radius", GUILayout.Width(LABEL_WIDTH));
			currentCollider.radiusAdjust = EditorGUILayout.Slider(currentCollider.radiusAdjust, -0.1f, 0.1f);
			GUILayout.EndHorizontal();

			if (currentCollider.collider.GetType() == typeof(CapsuleCollider))
			{
				GUILayout.BeginHorizontal();
				GUILayout.Space(GUTTER);
				GUILayout.Label("Height", GUILayout.Width(LABEL_WIDTH));
				currentCollider.heightAdjust = EditorGUILayout.Slider(currentCollider.heightAdjust, -0.1f, 0.1f);
				GUILayout.EndHorizontal();
			}

			GUILayout.Space(8f);

			GUILayout.BeginHorizontal();
			GUILayout.Space(GUTTER);
			GUILayout.Label("X (loc)", GUILayout.Width(LABEL_WIDTH));
			currentCollider.xAdjust = EditorGUILayout.Slider(currentCollider.xAdjust, -0.1f, 0.1f);
			GUILayout.EndHorizontal();

			GUILayout.BeginHorizontal();
			GUILayout.Space(GUTTER);
			GUILayout.Label("Y (loc)", GUILayout.Width(LABEL_WIDTH));
			currentCollider.yAdjust = EditorGUILayout.Slider(currentCollider.yAdjust, -0.1f, 0.1f);
			GUILayout.EndHorizontal();

			GUILayout.BeginHorizontal();
			GUILayout.Space(GUTTER);
			GUILayout.Label("Z (loc)", GUILayout.Width(LABEL_WIDTH));
			currentCollider.zAdjust = EditorGUILayout.Slider(currentCollider.zAdjust, -0.1f, 0.1f);
			GUILayout.EndHorizontal();

			GUILayout.Space(8f);

			GUILayout.BeginHorizontal();
			GUILayout.Space(GUTTER);
			GUILayout.Label("X (rot)", GUILayout.Width(LABEL_WIDTH));
			currentCollider.xRotate = EditorGUILayout.Slider(currentCollider.xRotate, -90f, 90f);
			GUILayout.EndHorizontal();

			GUILayout.BeginHorizontal();
			GUILayout.Space(GUTTER);
			GUILayout.Label("Y (rot)", GUILayout.Width(LABEL_WIDTH));
			currentCollider.yRotate = EditorGUILayout.Slider(currentCollider.yRotate, -90f, 90f);
			GUILayout.EndHorizontal();

			GUILayout.BeginHorizontal();
			GUILayout.Space(GUTTER);
			GUILayout.Label("Z (rot)", GUILayout.Width(LABEL_WIDTH));
			currentCollider.zRotate = EditorGUILayout.Slider(currentCollider.zRotate, -90f, 90f);
			GUILayout.EndHorizontal();

			GUILayout.Space(8f);

			GUILayout.BeginHorizontal();
			GUILayout.Space(GUTTER);
			GUILayout.Label("Symetrical", GUILayout.Width(LABEL_WIDTH));
			symmetrical = EditorGUILayout.Toggle(symmetrical);
			GUILayout.EndHorizontal();

			GUILayout.BeginHorizontal();
			GUILayout.Space(GUTTER);
			GUILayout.Label("", GUILayout.Width(LABEL_WIDTH));
			if (GUILayout.Button("Reset", GUILayout.Width(80f)))
			{
				currentCollider.Reset();
				if (symmetrical) UpdateSymmetrical(SymmetricalUpdateType.Reset);
			}
			GUILayout.Space(10f);
			if (GUILayout.Button("Set", GUILayout.Width(80f)))
			{
				currentCollider.FetchSettings();
				if (symmetrical) UpdateSymmetrical(SymmetricalUpdateType.Fetch);
			}
			GUILayout.EndHorizontal();
			GUILayout.Space(10f);
			GUILayout.BeginHorizontal();
			GUILayout.Space(GUTTER);
			GUILayout.Label("", GUILayout.Width(LABEL_WIDTH));			
			if (GUILayout.Button("Select", GUILayout.Width(80f)))
            {
				Selection.activeObject = currentCollider.collider;
            }
			GUILayout.EndHorizontal();

			if (EditorGUI.EndChangeCheck())
			{
				currentCollider.Update();
				if (symmetrical) UpdateSymmetrical(SymmetricalUpdateType.Update);
			}
			
			*/
            GUILayout.EndVertical();
            GUI.backgroundColor = background;

            GUILayout.Space(10f);

			
            EditorGUILayout.HelpBox("If changing the colliders directly, use the Rebuild Settings button to update to the new Collider settings.", MessageType.Info, true);

			GUILayout.BeginHorizontal();
			GUILayout.FlexibleSpace();
			if (GUILayout.Button("Rebuild Settings", GUILayout.Width(BUTTON_WIDTH)))
			{
				colliderManager.RefreshData();
				InitCurrentCollider(CURRENT_COLLIDER_NAME);
			}
			GUILayout.FlexibleSpace();
			GUILayout.EndHorizontal();

			GUILayout.Space(10f);

			EditorGUILayout.HelpBox("Settings can be saved in play mode and reloaded after play mode ends.", MessageType.Info, true);

			GUILayout.BeginHorizontal();
			GUILayout.FlexibleSpace();
			GUI.backgroundColor = Color.Lerp(background, Color.red, 0.25f);
			if (GUILayout.Button("Save Settings", GUILayout.Width(BUTTON_WIDTH)))
			{
				PhysicsSettingsStore.SaveColliderSettings(colliderManager);
			}
			GUI.backgroundColor = background;
			GUILayout.Space(10f);			
			GUI.backgroundColor = Color.Lerp(background, Color.yellow, 0.25f);
			if (GUILayout.Button("Recall Settings", GUILayout.Width(BUTTON_WIDTH)))
			{
				PhysicsSettingsStore.RecallColliderSettings(colliderManager);
			}
			GUI.backgroundColor = background;			
			GUILayout.FlexibleSpace();
			GUILayout.EndHorizontal();

			GUILayout.Space(10f);

			GUILayout.BeginHorizontal();
			GUILayout.FlexibleSpace();
			if (Application.isPlaying) GUI.enabled = false;
			GUI.backgroundColor = Color.Lerp(background, Color.cyan, 0.25f);
			if (GUILayout.Button("Apply to Prefab", GUILayout.Width(BUTTON_WIDTH)))
			{
				UpdatePrefab(colliderManager);
			}
			GUI.enabled = true;
			GUI.backgroundColor = background;
			GUILayout.FlexibleSpace();
			GUILayout.EndHorizontal();			

			GUILayout.Space(10f);

			GUILayout.BeginHorizontal();
			GUILayout.Label("Cloth Meshes", EditorStyles.boldLabel);
			GUILayout.BeginVertical();
			
			GUI.backgroundColor = Color.Lerp(background, Color.green, 0.25f);
			foreach (GameObject clothMesh in colliderManager.clothMeshes)
            {
				GUILayout.BeginHorizontal();
				GUILayout.FlexibleSpace();
				if (GUILayout.Button(clothMesh.name, GUILayout.Width(160f)))
				{
					Selection.activeObject = clothMesh;
				}
				GUILayout.FlexibleSpace();
				GUILayout.EndHorizontal();
				GUILayout.Space(4f);
			}
			GUI.backgroundColor = background;
			GUILayout.EndVertical();
			GUILayout.EndHorizontal();
		}

        // tracking logic:
        // animplayer bone tracking implicitly selects an object and frames the sceneview with it
        // this always deselects the collider manager
        //
        // have a tracking capability in the collider manager 
        // this should do the following:
        // - when on should highlight the collider manager with a red box or something conspicuous 
        // - prevent bone tracking in the anim player from working
        // - lock the inspector to the collider manager
        // - fold in all components but the collider manager (possible?)
        // - select the collider object to track & frame that object for active scene camera following
        // - manually draw all the collider gizmos 
        // - make it so play mode can be entered smoothly

        private void OnColliderControlGUI()
        {
            if (colliderManagerStyles == null) colliderManagerStyles = new Styles();

            GUILayout.BeginVertical();
            GUILayout.Space(10f);
            
            GUILayout.BeginHorizontal();
            GUILayout.Space(10f);

            EditorGUI.BeginChangeCheck();
            
            locked = ActiveEditorTracker.sharedTracker.isLocked;
            string lookIcon = locked ? "d_SceneViewVisibility On" : "d_ViewToolOrbit On";
            if (GUILayout.Button(new GUIContent(EditorGUIUtility.IconContent(lookIcon).image, "")))
            {
                if (!locked)
                {
                    locked = true;
					if (colliderManager.selectedAbstractCapsuleCollider != null)
						FocusPosition(colliderManager.selectedAbstractCapsuleCollider.transform.position);
                    Selection.activeObject = colliderManager.gameObject;
                    ActiveEditorTracker.sharedTracker.isLocked = locked;
                    ActiveEditorTracker.sharedTracker.ForceRebuild();

                }
                else
                {
                    locked = false;

                    Selection.activeObject = null;
                    ActiveEditorTracker.sharedTracker.isLocked = locked;
                    ActiveEditorTracker.sharedTracker.ForceRebuild();
                }
            }            
            if (EditorGUI.EndChangeCheck())
            {
                SceneView.RepaintAll();
            }
            GUILayout.FlexibleSpace();
            GUILayout.EndHorizontal();

            GUILayout.EndVertical();

            GUILayout.BeginVertical();
            GUILayout.Space(10f);
			if (colliderManager.abstractedCapsuleColliders != null)
			{
				foreach (ColliderManager.AbstractCapsuleCollider c in colliderManager.abstractedCapsuleColliders)
				{
                    bool active = (c == colliderManager.selectedAbstractCapsuleCollider);
                    GUILayout.BeginVertical();

                    GUILayout.BeginHorizontal();
					GUILayout.Space(10f);

                    if (GUILayout.Button(c.name, (active ? colliderManagerStyles.currentButton : colliderManagerStyles.normalButton), GUILayout.MaxWidth(250f)))
					{
                        TurnOnGizmos();

                        colliderManager.selectedAbstractCapsuleCollider = c;
						colliderManager.mirrorImageAbstractCapsuleCollider = DetermineMirrorImageCollider(c);
                        colliderManager.CacheCollider(colliderManager.selectedAbstractCapsuleCollider, colliderManager.mirrorImageAbstractCapsuleCollider);

                        if (Reallusion.Import.AnimPlayerGUI.IsPlayerShown() && Reallusion.Import.AnimPlayerGUI.isTracking)
						{
							GameObject go = Reallusion.Import.AnimPlayerGUI.lastTracked;
							locked = true;
							FocusPosition(colliderManager.selectedAbstractCapsuleCollider.transform.position);
							Selection.activeObject = colliderManager.gameObject;
							ActiveEditorTracker.sharedTracker.isLocked = locked;
							ActiveEditorTracker.sharedTracker.ForceRebuild();
							Selection.activeObject = go;
						}
						else
						{
							FocusPosition(colliderManager.selectedAbstractCapsuleCollider.transform.position);
						}
						SceneView.RepaintAll();
					}
                    GUILayout.EndHorizontal();

                    if (active)
					{
                        GUILayout.Space(2f);
                        DrawEditModeControls();
					}

                    GUILayout.EndVertical();
                    if (active)
						GUILayout.Space(2f);
				}
			}
            GUILayout.Space(10f);

            GUILayout.BeginHorizontal();
            GUILayout.Space(10f);

            EditorGUI.BeginChangeCheck();
            colliderManager.transformSymmetrically = GUILayout.Toggle(colliderManager.transformSymmetrically, new GUIContent("Symmetrical Transformation"));
            if (EditorGUI.EndChangeCheck())
            {
                SceneView.RepaintAll();
				if (colliderManager.selectedAbstractCapsuleCollider != null)
				{
					colliderManager.mirrorImageAbstractCapsuleCollider = DetermineMirrorImageCollider(colliderManager.selectedAbstractCapsuleCollider);
					FocusPosition(colliderManager.selectedAbstractCapsuleCollider.transform.position);
				}
            }
            GUILayout.Space(10f);
            EditorGUI.BeginChangeCheck();
            colliderManager.frameSymmetryPair = GUILayout.Toggle(colliderManager.frameSymmetryPair, new GUIContent("Frame Pair"));
            if (EditorGUI.EndChangeCheck())
            {
                SceneView.RepaintAll();
                if (colliderManager.selectedAbstractCapsuleCollider != null)
                {
                    colliderManager.mirrorImageAbstractCapsuleCollider = DetermineMirrorImageCollider(colliderManager.selectedAbstractCapsuleCollider);
                    FocusPosition(colliderManager.selectedAbstractCapsuleCollider.transform.position);
                }
            }

            GUILayout.EndHorizontal();

            GUILayout.Space(10f);
            GUILayout.EndVertical();
			if (processAfterGUI)
			{                
                // reset the collider to the cached values
                colliderManager.ResetColliderFromCache();
                // deselect the collider for editing
                colliderManager.selectedAbstractCapsuleCollider = null;
                colliderManager.mirrorImageAbstractCapsuleCollider = null;
                SceneView.RepaintAll();
				processAfterGUI = false;
            }
        }

		public void DrawEditModeControls()
		{
            GUILayout.BeginHorizontal();
            GUILayout.Space(10f);
            if (GUILayout.Button(new GUIContent(EditorGUIUtility.IconContent("d_clear").image, "Reset Collider"), colliderManagerStyles.normalButton, GUILayout.Width(30f)))
            {
                processAfterGUI = true;
            }
            GUILayout.Space(0f);
            GUIStyle style = (colliderManager.manipulator == ColliderManager.ManipulatorType.position ? colliderManagerStyles.currentButton : colliderManagerStyles.normalButton);
            if (GUILayout.Button(new GUIContent(EditorGUIUtility.IconContent("d_MoveTool on").image, "Transform position tool"), style, GUILayout.Width(30f)))
            {
                colliderManager.manipulator = ColliderManager.ManipulatorType.position;
                SceneView.RepaintAll();
            }
            GUILayout.Space(0f);
            style = (colliderManager.manipulator == ColliderManager.ManipulatorType.rotation ? colliderManagerStyles.currentButton : colliderManagerStyles.normalButton);
            if (GUILayout.Button(new GUIContent(EditorGUIUtility.IconContent("d_RotateTool On").image, "Transform rotation tool"), style, GUILayout.Width(30f)))
            {
                colliderManager.manipulator = ColliderManager.ManipulatorType.rotation;
                SceneView.RepaintAll();
            }
            GUILayout.Space(0f);
            style = (colliderManager.manipulator == ColliderManager.ManipulatorType.scale ? colliderManagerStyles.currentButton : colliderManagerStyles.normalButton);
            if (GUILayout.Button(new GUIContent(EditorGUIUtility.IconContent("ScaleTool On").image, "Transform scale tool"), style, GUILayout.Width(30f)))
            {
                colliderManager.manipulator = ColliderManager.ManipulatorType.scale;
                SceneView.RepaintAll();
            }
            GUILayout.EndHorizontal();
        }
		
        public void UpdatePrefab(Object component)
		{
			WindowManager.HideAnimationPlayer(true);
			WindowManager.HideAnimationRetargeter(true);

			GameObject prefabRoot = PrefabUtility.GetOutermostPrefabInstanceRoot(component);			
			if (prefabRoot)
			{									
				// reset collider states
				ColliderManager colliderManager = prefabRoot.GetComponentInChildren<ColliderManager>();
				if (colliderManager)
				{
					foreach (ColliderSettings cs in colliderManager.settings)
					{
						cs.Reset(true);						
					}
				}

				// save prefab asset
				PrefabUtility.ApplyPrefabInstance(prefabRoot, InteractionMode.UserAction);
			}
		}

		enum SymmetricalUpdateType { None, Update, Fetch, Reset }

		private ColliderManager.AbstractCapsuleCollider DetermineMirrorImageCollider(ColliderManager.AbstractCapsuleCollider collider)
		{
			if (!colliderManager.transformSymmetrically) { return null; }
			//Debug.Log("Determining mirror image for: " + collider.name);
			ColliderManager.AbstractCapsuleCollider mirrorCollider = null;
			string name = collider.name;
            string symName = null;
            colliderManager.selectedMirrorPlane = ColliderManager.MirrorPlane.x;

            if (name.Contains("_L_"))
            {
                symName = name.Replace("_L_", "_R_");
            }
            else if (name.Contains("_R_"))
            {
                symName = name.Replace("_R_", "_L_");
            }            
			else if (name == "CC_Base_NeckTwist01_Capsule(1)")
            {
                symName = "CC_Base_NeckTwist01_Capsule(2)";
            }
            else if (name == "CC_Base_NeckTwist01_Capsule(2)")
            {
                symName = "CC_Base_NeckTwist01_Capsule(1)";
            }
            else if (name == "CC_Base_Hip_Capsule")
            {
                symName = "CC_Base_Hip_Capsule(0)";
            }
            else if (name == "CC_Base_Hip_Capsule(0)")
            {
                symName = "CC_Base_Hip_Capsule";
            }
			
            mirrorCollider = colliderManager.abstractedCapsuleColliders.Find(x  => x.name == symName);
            //Debug.Log("Mirror image name: " + symName + " - Mirror collider: " + mirrorCollider.name);
            return mirrorCollider;
        }

		private void UpdateSymmetrical(SymmetricalUpdateType type)
		{
			string name = currentCollider.name;

			string boneName = name.Remove(name.IndexOf("_Capsule"));
			string symName = null;
			//Debug.Log(boneName);

			if (boneName.Contains("_L_"))
			{
				symName = boneName.Replace("_L_", "_R_");
			}
			else if (boneName.Contains("_R_"))
			{
				symName = boneName.Replace("_R_", "_L_");
			}
			else if (boneName.Contains("_Hip"))
			{
				symName = boneName;				
			}				

			if (!string.IsNullOrEmpty(symName))
			{
				foreach (ColliderSettings cs in colliderManager.settings)
				{
					if (cs != currentCollider && cs.name.StartsWith(symName))
					{
						if (type == SymmetricalUpdateType.Update)
						{
							cs.MirrorX(currentCollider);
							cs.Update();
						}
						else if (type == SymmetricalUpdateType.Reset)
						{
							cs.Reset();
						}
						else if (type == SymmetricalUpdateType.Fetch)
						{
							cs.FetchSettings();
						}
					}
				}
			}

			symName = null;

			if (name == "CC_Base_NeckTwist01_Capsule(1)")
			{
				symName = "CC_Base_NeckTwist01_Capsule(2)";
			}
			else if (name == "CC_Base_NeckTwist01_Capsule(2)")
			{
				symName = "CC_Base_NeckTwist01_Capsule(1)";
			}

			if (!string.IsNullOrEmpty(symName))
			{
				foreach (ColliderSettings cs in colliderManager.settings)
				{
					if (cs != currentCollider && cs.name.StartsWith(symName))
					{
						if (type == SymmetricalUpdateType.Update)
						{
							cs.MirrorZ(currentCollider);
							cs.Update();
						}
						else if (type == SymmetricalUpdateType.Reset)
						{
							cs.Reset();
						}
						else if (type == SymmetricalUpdateType.Fetch)
						{
							cs.FetchSettings();
						}
					}
				}
			}
		}

		private void SelectCurrentCollider(object sel)
		{
			currentCollider = (ColliderSettings)sel;
			if (currentCollider != null)
			{
				CURRENT_COLLIDER_NAME = currentCollider.name;
			}
		}

        public static void DrawWireCapsule(Vector3 _pos, Quaternion _rot, float _radius, float _height, Color _color = default(Color))
        {
            if (_color != default(Color))
                Handles.color = _color;
            Matrix4x4 angleMatrix = Matrix4x4.TRS(_pos, _rot, Handles.matrix.lossyScale);
            using (new Handles.DrawingScope(angleMatrix))
            {
                var pointOffset = (_height - (_radius * 2)) / 2;

                //draw sideways
                Handles.DrawWireArc(Vector3.up * pointOffset, Vector3.left, Vector3.back, -180, _radius);
                Handles.DrawLine(new Vector3(0, pointOffset, -_radius), new Vector3(0, -pointOffset, -_radius));
                Handles.DrawLine(new Vector3(0, pointOffset, _radius), new Vector3(0, -pointOffset, _radius));
                Handles.DrawWireArc(Vector3.down * pointOffset, Vector3.left, Vector3.back, 180, _radius);
                //draw frontways
                Handles.DrawWireArc(Vector3.up * pointOffset, Vector3.back, Vector3.left, 180, _radius);
                Handles.DrawLine(new Vector3(-_radius, pointOffset, 0), new Vector3(-_radius, -pointOffset, 0));
                Handles.DrawLine(new Vector3(_radius, pointOffset, 0), new Vector3(_radius, -pointOffset, 0));
                Handles.DrawWireArc(Vector3.down * pointOffset, Vector3.back, Vector3.left, -180, _radius);
                //draw center
                Handles.DrawWireDisc(Vector3.up * pointOffset, Vector3.up, _radius);
                Handles.DrawWireDisc(Vector3.down * pointOffset, Vector3.up, _radius);

            }
        }

        public static Texture2D TextureColor(Color color)
        {
            const int size = 32;
            Texture2D texture = new Texture2D(size, size);
            Color[] pixels = texture.GetPixels();
            for (int i = 0; i < pixels.Length; i++)
            {
                pixels[i] = color;
            }
            texture.SetPixels(pixels);
            texture.Apply(true);
            return texture;
        }

        public void FocusPosition(Vector3 pos)
        {
			Bounds framingBounds;
            float mult = 0.35f;

            if (colliderManager.transformSymmetrically && colliderManager.frameSymmetryPair && colliderManager.mirrorImageAbstractCapsuleCollider != null)
			{
				Vector3 diff = colliderManager.mirrorImageAbstractCapsuleCollider.transform.position + colliderManager.selectedAbstractCapsuleCollider.transform.position;
				Vector3 mid = diff / 2;
                float mag = diff.magnitude;

				if (mag > 2)
					mult = mag * 0.15f;
				else
					mult = mag * 0.4f;

                framingBounds = new Bounds(mid, Vector3.one * mult);
			}
			else
				framingBounds = new Bounds(pos, Vector3.one * mult);

            SceneView.lastActiveSceneView.Frame(framingBounds, false);
            SceneView.lastActiveSceneView.rotation = Quaternion.Euler(180f, 0f, 180f);
        }

		public bool TurnOnGizmos()
		{
			bool wereGizmosDrawn = SceneView.lastActiveSceneView.drawGizmos;
            if (!wereGizmosDrawn)
				SceneView.lastActiveSceneView.drawGizmos = true;

			return wereGizmosDrawn;
		}
    }
}






