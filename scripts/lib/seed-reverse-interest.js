/**
 * Dev helper: simulate test users who already tapped Interested on the viewer.
 */

async function seedReverseInterest(client, viewerUid, targetUid) {
  await client.query(
    `DELETE FROM interactions
     WHERE (actor_uid = $1 AND target_uid = $2)
        OR (actor_uid = $2 AND target_uid = $1)`,
    [viewerUid, targetUid]
  );

  await client.query(
    `INSERT INTO interactions(actor_uid, target_uid, type, source)
     VALUES ($1, $2, 'interested', 'daily_queue')`,
    [targetUid, viewerUid]
  );
}

async function listQueueTestTargets(pool, viewerUid, limit) {
  const result = await pool.query(
    `SELECT dq.profile_uid AS uid, p.display_name
     FROM daily_queue dq
     JOIN profiles p ON p.uid = dq.profile_uid
     WHERE dq.uid = $1
       AND dq.queue_date = CURRENT_DATE
       AND p.profile_extras->>'is_test_user' = 'true'
     ORDER BY dq.position ASC
     LIMIT $2`,
    [viewerUid, limit]
  );
  return result.rows;
}

async function seedReverseInterestForQueue(pool, viewerUid, { count = 3 } = {}) {
  const limit = Math.max(1, count);
  const targets = await listQueueTestTargets(pool, viewerUid, limit);
  if (targets.length === 0) {
    return [];
  }

  const seeded = [];
  for (const target of targets) {
    const client = await pool.connect();
    try {
      await client.query("BEGIN");
      await seedReverseInterest(client, viewerUid, target.uid);
      await client.query("COMMIT");
      seeded.push(target);
    } catch (error) {
      await client.query("ROLLBACK");
      throw error;
    } finally {
      client.release();
    }
  }
  return seeded;
}

module.exports = {
  seedReverseInterest,
  listQueueTestTargets,
  seedReverseInterestForQueue,
};
