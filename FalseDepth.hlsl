//UNITY_SHADER_NO_UPGRADE
#ifndef MYHLSLINCLUDE_INCLUDED
#define MYHLSLINCLUDE_INCLUDED
void FalseDepth_float(float3 CameraPosition, float3 VertexPosition, float3 RoomSize, out float3 WallDirection, out float3 WallNormal, out float Distance)
{
	float3 cameraToFragment = VertexPosition - CameraPosition;
	
	// Calculate room bounds: centered at (0.5, 0.5) in XY, extending from 0 to RoomSize.z in Z
	// This keeps the front of the room touching the visible quad at z=0
	float3 roomMin = float3(0.5 - RoomSize.x * 0.5, 0.5 - RoomSize.y * 0.5, 0.0);
	float3 roomMax = float3(0.5 + RoomSize.x * 0.5, 0.5 + RoomSize.y * 0.5, RoomSize.z);
	
	// Determine which walls to use based on ray direction
	float3 wallDistances = step(float3(0, 0, 0), cameraToFragment);
	float3 wallPositions = lerp(roomMin, roomMax, wallDistances);
	
	// Calculate ray fractions for each axis
	float3 rayFractions = (wallPositions - CameraPosition) / cameraToFragment;
	
	// Calculate intersection points on each plane
	float2 intersectionXY = (CameraPosition + rayFractions.z * cameraToFragment).xy;
	float2 intersectionXZ = (CameraPosition + rayFractions.y * cameraToFragment).xz;
	float2 intersectionZY = (CameraPosition + rayFractions.x * cameraToFragment).zy;
	
	// Determine which wall is hit first by comparing ray fractions
	float x_vs_z = step(rayFractions.x, rayFractions.z);
	float rayFraction_x_vs_z = lerp(rayFractions.z, rayFractions.x, x_vs_z);
	float x_z_vs_y = step(rayFraction_x_vs_z, rayFractions.y);
	
	// Construct 3D intersection points for each wall type
	float3 backWallIntersection = float3(intersectionXY.x, intersectionXY.y, wallPositions.z);
	float3 sideWallIntersection = float3(wallPositions.x, intersectionZY.y, intersectionZY.x);
	float3 floorCeilingIntersection = float3(intersectionXZ.x, wallPositions.y, intersectionXZ.y);
	
	// Select the correct intersection based on which wall was hit
	float3 wallIntersection = lerp(backWallIntersection, sideWallIntersection, x_vs_z);
	float3 finalIntersection = lerp(floorCeilingIntersection, wallIntersection, x_z_vs_y);
	
	// Calculate Point A: intersection with the visible plane at z=0
	float t_visible = (0.0 - CameraPosition.z) / cameraToFragment.z;
	float3 visiblePlaneIntersection = CameraPosition + t_visible * cameraToFragment;
	
	// Calculate distance between visible plane intersection and room wall intersection
	Distance = length(finalIntersection - visiblePlaneIntersection - float3(0, 0, RoomSize.z));
	
	// Center of the room (centered in XY, at half depth in Z)
	float3 cubeCenter = float3(0.5, 0.5, RoomSize.z * 0.5);
	
	// Vector from center to intersection point
	float3 scaledDirection = finalIntersection - cubeCenter;
	
	// Renormalize back to unit cube by dividing by RoomSize
	WallDirection = scaledDirection / RoomSize;
	
	// Calculate normals for each wall type (pointing inward)
	// Normal sign: if ray goes positive, wall normal points negative (inward)
	float3 normalSigns = 1.0 - 2.0 * wallDistances;
	float3 backWallNormal = float3(0, 0, normalSigns.z);
	float3 sideWallNormal = float3(normalSigns.x, 0, 0);
	float3 floorCeilingNormal = float3(0, normalSigns.y, 0);
	
	// Select the correct normal based on which wall was hit
	float3 wallNormalXZ = lerp(backWallNormal, sideWallNormal, x_vs_z);
	WallNormal = lerp(floorCeilingNormal, wallNormalXZ, x_z_vs_y);
}

void InteriorPlane_float(float3 CameraPosition, float3 VertexPosition, float3 RoomSize, out float3 PlaneDirection, out bool InsideOutside)
{
	float3 cameraToFragment = VertexPosition - CameraPosition;
	
	// The plane is positioned at half the room depth
	float planeZ = RoomSize.z * 0.5;
	
	// Calculate ray fraction to intersect the plane at z = planeZ
	float t = (planeZ - CameraPosition.z) / cameraToFragment.z;
	
	// Find the intersection point on the plane
	float3 intersection = CameraPosition + t * cameraToFragment;
	
	// Calculate room bounds in XY
	float2 roomMin = float2(0.5 - RoomSize.x * 0.5, 0.5 - RoomSize.y * 0.5);
	float2 roomMax = float2(0.5 + RoomSize.x * 0.5, 0.5 + RoomSize.y * 0.5);
	
	// Check if intersection is within room bounds
	// Returns 0 if inside, 1 if outside
	float2 insideBounds = step(roomMin, intersection.xy) * step(intersection.xy, roomMax);
	InsideOutside = 1 - (int)(insideBounds.x * insideBounds.y);
	
	// Get XY position relative to room center (room is centered at 0.5, 0.5)
	float2 xyFromCenter = intersection.xy - 0.5;
	
	// Renormalize by room size to maintain unit cube proportions
	float2 normalizedXY = xyFromCenter / RoomSize.xy;
	
	// Create direction vector that samples the -Z face of the cubemap
	// Z = -0.5 ensures we always sample the backfacing side
	// XY components determine the position on that face
	PlaneDirection = float3(normalizedXY.x, normalizedXY.y, -0.5);
}
#endif //MYHLSLINCLUDE_INCLUDED