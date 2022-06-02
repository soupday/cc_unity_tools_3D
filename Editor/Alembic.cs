using System.IO;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

namespace Reallusion.Import
{
    public class Alembic
    {

        public static List<string> FindAlembics(string characterName, string characterFolder)
        {
            List<string> alembicGuids = new List<string>();            

            string rootFolder = "Assets/Alembic/" + characterName;
            string charFolder = characterFolder + "/Alembic/" + characterName;

            List<string> folders = new List<string>();

            if (AssetDatabase.IsValidFolder(rootFolder))
                folders.Add(rootFolder);

            if (AssetDatabase.IsValidFolder(charFolder))
                folders.Add(charFolder);

            string[] guids;

            if (folders.Count > 0)
            {
                guids = AssetDatabase.FindAssets("t:gameobject", folders.ToArray());

                foreach (string guid in guids)
                {
                    string path = AssetDatabase.GUIDToAssetPath(guid);
                    string extention = Path.GetExtension(path);
                    if (extention.iEquals(".abc"))
                    {
                        alembicGuids.Add(guid);
                    }
                }
            }

            folders.Clear();
            folders.Add(characterFolder);
            guids = AssetDatabase.FindAssets(characterName + " t:gameobject", folders.ToArray());

            foreach (string guid in guids)
            {
                string path = AssetDatabase.GUIDToAssetPath(guid);
                string fileName = Path.GetFileNameWithoutExtension(path);
                string extention = Path.GetExtension(path);
                if (extention.iEquals(".abc") && fileName.iStartsWith(characterName))
                {
                    if (!alembicGuids.Contains(guid))
                        alembicGuids.Add(guid);
                }
            }

            return alembicGuids;
        }

        public static void ProcessAlembics(GameObject sourceFbx, string characterName, string characterFolder)
        {
            List<string> guids = FindAlembics(characterName, characterFolder);                        

            if (Util.FindCharacterPrefabs(sourceFbx, out GameObject mainPrefab, out GameObject bakedPrefab))
            {
                List<GameObject> sourcePrefabs = new List<GameObject>();
                List<GameObject> outputPrefabs = new List<GameObject>();
                if (mainPrefab) sourcePrefabs.Add(mainPrefab);
                if (bakedPrefab) sourcePrefabs.Add(bakedPrefab);                

                foreach (GameObject sourcePrefab in sourcePrefabs)
                {
                    string suffix = (sourcePrefab.name.Contains("_Baked")) ? "_Baked_Alembic" : "_Alembic";
                    List<MaterialMeshPair> materialMeshes;
                    Dictionary<string, Material> sourceMaterials = GetSourceMaterials(sourcePrefab, out materialMeshes);

                    foreach (string guid in guids)
                    {
                        string path = AssetDatabase.GUIDToAssetPath(guid);
                        string folder = Path.GetDirectoryName(path);
                        string fileName = Path.GetFileNameWithoutExtension(path);
                        string extention = Path.GetExtension(path);
                        string prefabSaveFolder = Path.Combine(folder, Importer.PREFABS_FOLDER, characterName + "_Alembic");
                        string prefabSavePath = Path.Combine(prefabSaveFolder, fileName + suffix + ".prefab");
                        Util.EnsureAssetsFolderExists(prefabSaveFolder);
                        GameObject prefab = AssetDatabase.LoadAssetAtPath<GameObject>(path);

                        GameObject scenePrefab = PrefabUtility.InstantiatePrefab(prefab) as GameObject;
                        if (scenePrefab)
                        {
                            MeshRenderer[] renderers = scenePrefab.GetComponentsInChildren<MeshRenderer>();                            

                            foreach (MeshRenderer renderer in renderers)
                            {
                                bool found = false;
                                Material mat = null;

                                string key = renderer.gameObject.name;
                                if (sourceMaterials.TryGetValue(key, out mat))
                                {
                                    renderer.sharedMaterial = mat;
                                    found = true;                                    
                                }
                                else
                                {
                                    MeshFilter mf = renderer.gameObject.GetComponent<MeshFilter>();
                                    Mesh m = mf.sharedMesh;
                                    int triangles = m.triangles.Length / 3;                                    

                                    foreach (MaterialMeshPair mmp in materialMeshes)
                                    {
                                        if (mmp.triangleCount == triangles)
                                        {
                                            mat = mmp.mat;
                                            renderer.sharedMaterial = mat;
                                            found = true;                                            
                                            break;
                                        }
                                    }
                                }

                                if (found && mat)
                                {
                                    if (mat.name.Contains("_1st_Pass"))
                                    {
                                        string key2 = mat.name.Replace("_1st_Pass", "_2nd_Pass");
                                        if (sourceMaterials.TryGetValue(key2, out Material mat2))
                                        {
                                            Material[] mats = new Material[] { mat, mat2 };
                                            renderer.sharedMaterials = mats;
                                        }
                                        else
                                        {
                                            foreach (MaterialMeshPair mmp2 in materialMeshes)
                                            {
                                                if (mmp2.mat.name.Equals(key2))
                                                {
                                                    Material[] mats = new Material[] { mat, mmp2.mat };
                                                    renderer.sharedMaterials = mats;
                                                    break;
                                                }
                                            }
                                        }
                                    }
                                }
                                else
                                {
                                    Debug.Log("Could not find material: " + key);
                                }
                            }
                        }                        

                        GameObject newPrefab = PrefabUtility.SaveAsPrefabAsset(scenePrefab, prefabSavePath);
                        outputPrefabs.Add(newPrefab);
                        UnityEngine.Object.DestroyImmediate(scenePrefab);
                    }
                }

                Selection.objects = outputPrefabs.ToArray();
            }
        }   

        public static void Fix(MeshRenderer renderer, Material mat)
        {
            
        }
        
        public struct MaterialMeshPair 
        { 
            public Material mat; 
            public int triangleCount;           
        }
        
        public static Dictionary<string, Material> GetSourceMaterials(GameObject sourcePrefab, out List<MaterialMeshPair> materialMeshes)
        {
            Dictionary<string, Material> materials = new Dictionary<string, Material>();
            materialMeshes = new List<MaterialMeshPair>();

            SkinnedMeshRenderer[] renderers = sourcePrefab.GetComponentsInChildren<SkinnedMeshRenderer>();
            foreach (SkinnedMeshRenderer renderer in renderers)
            {
                int index = 0;
                foreach (Material mat in renderer.sharedMaterials)
                {
                    string key;
                    string matName = mat.name;
                    string objName = renderer.gameObject.name;

                    Mesh mesh = renderer.sharedMesh;
                    int triangles = mesh.triangles.Length / 3;
                    if (mesh.subMeshCount > 1)
                        triangles = mesh.GetSubMesh(index).indexCount / 3;                    
                    materialMeshes.Add(new MaterialMeshPair() { mat = mat, triangleCount = triangles });

                    if (matName.Contains("_Transparency")) matName = matName.Replace("_Transparency", "");
                    if (matName.Contains("_Pbr")) matName = matName.Replace("_Pbr", "");

                    if (objName.Contains("_Extracted"))
                    {
                        int i = objName.IndexOf("_Extracted");
                        objName = objName.Substring(0, i);
                    }
                    
                    if (renderer.sharedMaterials.Length == 1)
                    {
                        // single material key
                        key = objName + "Shape";
                        if (!materials.ContainsKey(key)) materials.Add(key, mat);
                    }
                    else
                    {
                        // multi-material key
                        key = objName + "-" + matName + "Shape";
                        if (!materials.ContainsKey(key)) materials.Add(key, mat);
                    }

                    // try some variations to catch the combined body meshes:
                    if (renderer.sharedMaterials.Length > 1)
                    {
                        if (matName.iContains("std_eye") || matName.iContains("std_cornea"))
                        {
                            key = "CC_Base_Eye" + "-" + matName + "Shape";
                            if (!materials.ContainsKey(key)) materials.Add(key, mat);

                            key = "CC_Game_Eye" + "-" + matName + "Shape";
                            if (!materials.ContainsKey(key)) materials.Add(key, mat);
                        }

                        if (matName.iContains("std_teeth"))
                        {
                            key = "CC_Base_Teeth" + "-" + matName + "Shape";
                            if (!materials.ContainsKey(key)) materials.Add(key, mat);

                            key = "CC_Game_Teeth" + "-" + matName + "Shape";
                            if (!materials.ContainsKey(key)) materials.Add(key, mat);
                        }

                        if (matName.iContains("std_tongue"))
                        {
                            key = "CC_Base_Tongue" + "-" + matName + "Shape";
                            if (!materials.ContainsKey(key)) materials.Add(key, mat);

                            key = "CC_Game_Tongue" + "-" + matName + "Shape";
                            if (!materials.ContainsKey(key)) materials.Add(key, mat);
                        }

                        // catch multi-pass materials
                        if (matName.iContains("_1st_pass"))
                        {
                            matName = matName.Replace("_1st_Pass", "");

                            key = objName + "Shape";
                            if (!materials.ContainsKey(key)) materials.Add(key, mat);

                            key = objName + "-" + matName + "Shape";
                            if (!materials.ContainsKey(key)) materials.Add(key, mat);
                        }
                    }

                    index++;
                }
            }

            return materials;
        }

    }
}