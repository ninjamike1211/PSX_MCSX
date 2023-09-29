// Primitives


float maxof(vec3 x) { return max(x.x, max(x.y, x.z)); }
float minof(vec3 x) { return min(x.x, min(x.y, x.z)); }

bool IntersectAABB(vec3 pos, vec3 dir, vec3 minBounds, vec3 maxBounds) {
    vec3 minBoundsDist = ((minBounds - pos) / dir);
    vec3 maxBoundsDist = ((maxBounds - pos) / dir);
    
    vec3 minDists = min(minBoundsDist, maxBoundsDist);
    vec3 maxDists = max(minBoundsDist, maxBoundsDist);
    
    ivec3 a = floatBitsToInt(minDists.xxy - maxDists.yzx);
    ivec3 b = floatBitsToInt(minDists.yzz - maxDists.zxy);
    a = a & b;
    return (a.x & a.y & a.z) < 0;
}

bool IntersectBlock(vec3 origin, ivec3 index, vec3 direction, out vec3 hitPos, inout vec3 hitNormal) {
	vec3 minBoundsDist = (      index - origin) / direction;
	vec3 maxBoundsDist = (1.0 + index - origin) / direction;

	vec3 positiveDir = step(0.0, direction);
	vec3 dists       = mix(maxBoundsDist, minBoundsDist, positiveDir);

	float dist;
	if (dists.x > dists.y) {
		if (dists.x > dists.z) {
			dist = dists.x;
			hitNormal = vec3(-positiveDir.x * 2.0 + 1.0, 0.0, 0.0);
		} else {
			dist = dists.z;
			hitNormal = vec3(0.0, 0.0, -positiveDir.z * 2.0 + 1.0);
		}
	} else if (dists.y > dists.z) {
		dist = dists.y;
		hitNormal = vec3(0.0, -positiveDir.y * 2.0 + 1.0, 0.0);
	} else {
		dist = dists.z;
		hitNormal = vec3(0.0, 0.0, -positiveDir.z * 2.0 + 1.0);
	}

	hitPos = dist * direction + origin;

	return dist > 0.0;
}

bool IntersectVoxel(vec3 origin, ivec3 index, vec3 direction, int id, out vec3 hitPos, inout vec3 hitNormal) {
	// default value
	hitPos = origin;

	// if(id >= 108 && id <= 145) {
	// 	vec3[38][2] bounds = vec3[38][2](
	// 		// Buttons
	// 		vec3[2](vec3(0.0000, 0.3750, 0.3125), vec3(0.1250, 0.6250, 0.6875)),
	// 		vec3[2](vec3(0.8750, 0.3750, 0.3125), vec3(1.0000, 0.6250, 0.6875)),
	// 		vec3[2](vec3(0.3125, 0.3750, 0.0000), vec3(0.6875, 0.6250, 0.1250)),
	// 		vec3[2](vec3(0.3250, 0.3750, 0.8750), vec3(0.6875, 0.6250, 1.0000)),
	// 		vec3[2](vec3(0.3750, 0.0000, 0.3125), vec3(0.6250, 0.1250, 0.6875)),
	// 		vec3[2](vec3(0.3125, 0.0000, 0.3750), vec3(0.6875, 0.1250, 0.6250)),
	// 		vec3[2](vec3(0.3750, 0.8750, 0.3125), vec3(0.6250, 1.0000, 0.6875)),
	// 		vec3[2](vec3(0.3125, 0.8750, 0.3750), vec3(0.6875, 1.0000, 0.6250)),
	// 		vec3[2](vec3(0.0000, 0.3750, 0.3125), vec3(0.0625, 0.6250, 0.6875)),
	// 		vec3[2](vec3(0.9375, 0.3750, 0.3125), vec3(1.0000, 0.6250, 0.6875)),
	// 		vec3[2](vec3(0.3125, 0.3750, 0.0000), vec3(0.6875, 0.6250, 0.0625)),
	// 		vec3[2](vec3(0.3125, 0.3750, 0.9375), vec3(0.6875, 0.6250, 1.0000)),
	// 		vec3[2](vec3(0.3750, 0.0000, 0.3125), vec3(0.6250, 0.0625, 0.6875)),
	// 		vec3[2](vec3(0.3125, 0.0000, 0.3750), vec3(0.6875, 0.0625, 0.6250)),
	// 		vec3[2](vec3(0.3750, 0.9375, 0.3125), vec3(0.6250, 1.0000, 0.6875)),
	// 		vec3[2](vec3(0.3125, 0.9375, 0.3750), vec3(0.6875, 1.0000, 0.6250)),

	// 		// Slabs
	// 		vec3[2](vec3(0.0000, 0.0000, 0.0000), vec3(1.0000, 0.5000, 1.0000)),
	// 		vec3[2](vec3(0.0000, 0.5000, 0.0000), vec3(1.0000, 1.0000, 1.0000)),

	// 		// Pressure plates
	// 		vec3[2](vec3(0.0625, 0.0000, 0.0625), vec3(0.9375, 0.06250, 0.9375)),
	// 		vec3[2](vec3(0.0625, 0.0000, 0.0625), vec3(0.9375, 0.03125, 0.9375)),

	// 		// Water, Lava
	// 		vec3[2](vec3(0.0000, 0.0000, 0.0000), vec3(1.0000, 8.0/9.0, 1.0000)),
	// 		vec3[2](vec3(0.0000, 0.0000, 0.0000), vec3(1.0000, 8.0/9.0, 1.0000)),

	// 		// Torch
	// 		vec3[2](vec3(0.4375, 0.0000, 0.4375), vec3(0.5625, 0.6250, 0.5625)),

	// 		// Doors, trapdoors
	// 		vec3[2](vec3(0.0000, 0.0000, 0.0000), vec3(1.0000, 0.1875, 1.0000)),
	// 		vec3[2](vec3(0.0000, 0.0000, 0.0000), vec3(0.1875, 1.0000, 1.0000)),
	// 		vec3[2](vec3(0.8125, 0.0000, 0.0000), vec3(1.0000, 1.0000, 1.0000)),
	// 		vec3[2](vec3(0.0000, 0.0000, 0.0000), vec3(1.0000, 1.0000, 0.1875)),
	// 		vec3[2](vec3(0.0000, 0.0000, 0.8125), vec3(1.0000, 1.0000, 1.0000)),
	// 		vec3[2](vec3(0.0000, 0.8125, 0.0000), vec3(1.0000, 1.0000, 1.0000)),
	// 		// Grass path, farmland
	// 		vec3[2](vec3(0.0000, 0.0000, 0.0000), vec3(1.0000, 0.9375, 1.0000)),
	// 		// Carpets, snow and misc blocks
	// 		vec3[2](vec3(0.0000, 0.0000, 0.0000), vec3(1.0000, 0.0625, 1.0000)),
	// 		vec3[2](vec3(0.0000, 0.0000, 0.0000), vec3(1.0000, 0.1250, 1.0000)),
	// 		vec3[2](vec3(0.0000, 0.0000, 0.0000), vec3(1.0000, 0.2500, 1.0000)),
	// 		vec3[2](vec3(0.0000, 0.0000, 0.0000), vec3(1.0000, 0.3750, 1.0000)),
	// 		vec3[2](vec3(0.0000, 0.0000, 0.0000), vec3(1.0000, 0.5000, 1.0000)),
	// 		vec3[2](vec3(0.0000, 0.0000, 0.0000), vec3(1.0000, 0.6250, 1.0000)),
	// 		vec3[2](vec3(0.0000, 0.0000, 0.0000), vec3(1.0000, 0.7500, 1.0000)),
	// 		vec3[2](vec3(0.0000, 0.0000, 0.0000), vec3(1.0000, 0.8750, 1.0000))
	// 	);

	// 	float dist;
	// 	bool hit = IntersectAABB(origin - index, direction, bounds[id-108][0], bounds[id-108][1], dist, hitNormal);
	// 	hitPos = origin + direction * dist;
	// 	return hit;
	// }
	return IntersectBlock(origin, index, direction, hitPos, hitNormal);
}

// bool IntersectVoxelAlphatest(vec3 origin, ivec3 index, vec3 direction, vec4[2] voxel, int id, out vec3 hitPos, inout vec3 hitNormal) {
// 	if (IntersectVoxel(origin, index, direction, id, hitPos, hitNormal)) {
// 		// Perform alpha test
// 		Material voxelMaterial = MaterialFromVoxel(hitPos, hitNormal, voxel);
// 		return voxelMaterial.opacity > 0.102;
// 	}

// 	return false;
// }

bool RaytraceVoxel(vec3 origin, ivec3 originIndex, vec3 direction, bool transmit, const int maxSteps, out vec4[2] voxel, out vec3 hitPos, out ivec3 hitIndex, out vec3 hitNormal) {
	
	voxel = ReadVoxel(originIndex);
	hitIndex = originIndex;

	int id = ExtractVoxelId(voxel);
	if (id > 0 && !transmit) {
		if (IntersectVoxel(origin, originIndex, direction, id, hitPos, hitNormal)) {
			return true;
		}
	}

	vec3 deltaDist;
	vec3 next;
	ivec3 deltaSign;
	for (int axis = 0; axis < 3; ++axis) {
		deltaDist[axis] = length(direction / direction[axis]);
		if (direction[axis] < 0.0) {
			deltaSign[axis] = -1;
			next[axis] = (origin[axis] - hitIndex[axis]) * deltaDist[axis];
		} else {
			deltaSign[axis] = 1;
			next[axis] = (hitIndex[axis] + 1.0 - origin[axis]) * deltaDist[axis];
		}
	}

	bool hit = false;

	for (int i = 0; i < maxSteps && !hit; ++i) {
		if (next.x > next.y) {
			if (next.y > next.z) {
				next.z += deltaDist.z;
				hitIndex.z += deltaSign.z;
			} else {
				next.y += deltaDist.y;
				hitIndex.y += deltaSign.y;
			}
		} else if (next.x > next.z) {
			next.z += deltaDist.z;
			hitIndex.z += deltaSign.z;
		} else {
			next.x += deltaDist.x;
			hitIndex.x += deltaSign.x;
		}

		if (!IsInVoxelizationVolume(hitIndex)) { break; }

		voxel = ReadVoxel(hitIndex);
		id = ExtractVoxelId(voxel);
		if (id > 0) {
			hit = IntersectVoxel(origin, hitIndex, direction, id, hitPos, hitNormal);
		}
	}

	return hit;
}