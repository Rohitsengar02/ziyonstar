const Booking = require('../models/Booking');
const Technician = require('../models/Technician');
const User = require('../models/User');
const Dispute = require('../models/Dispute');

exports.getDashboardStats = async (req, res) => {
    try {
        const now = new Date();
        const startOfDay = new Date(now.setHours(0, 0, 0, 0));
        const startOfWeek = new Date(now.setDate(now.getDate() - now.getDay())); // Sunday
        const startOfMonth = new Date(now.getFullYear(), now.getMonth(), 1);

        // 1. KPI Metrics
        const totalOrders = await Booking.countDocuments();
        const completedOrders = await Booking.countDocuments({ status: 'Completed' });
        const activeTechs = await Technician.countDocuments({ status: { $in: ['active', 'approved'] } });

        // Revenue Calculation (Aggregation)
        const revenueAgg = await Booking.aggregate([
            { $match: { status: 'Completed' } },
            { $group: { _id: null, total: { $sum: '$totalPrice' } } }
        ]);
        const totalRevenue = revenueAgg.length > 0 ? revenueAgg[0].total : 0;

        // Estimated Payouts (assuming 85% payout) & Commission (15%)
        const pendingPayouts = totalRevenue * 0.85;
        const adminCommission = totalRevenue * 0.15;

        // Dispute Breakdown
        const disputeAgg = await Dispute.aggregate([
            { $group: { _id: '$status', count: { $sum: 1 } } }
        ]);
        const disputeStats = {
            open: 0,
            resolved: 0,
            investigation: 0
        };
        disputeAgg.forEach(d => {
            if (d._id === 'Pending') disputeStats.open += d.count;
            if (d._id === 'Investigation') disputeStats.investigation += d.count;
            if (d._id === 'Resolved') disputeStats.resolved += d.count;
        });

        // 2. Orders Overview
        const todayOrders = await Booking.countDocuments({ createdAt: { $gte: startOfDay } });
        // Reset 'now' for weekly calculation as setDate modifies it
        const todayForWeek = new Date();
        const weekStart = new Date(todayForWeek.setDate(todayForWeek.getDate() - 7));
        const weeklyOrders = await Booking.countDocuments({ createdAt: { $gte: weekStart } });

        const monthOrders = await Booking.countDocuments({ createdAt: { $gte: startOfMonth } });

        const ongoingOrders = await Booking.countDocuments({ status: { $in: ['In_Progress', 'On_Way', 'Arrived'] } });
        const scheduledOrders = await Booking.countDocuments({ status: 'Pending_Assignment' }); // Or 'Accepted'
        const cancelledOrders = await Booking.countDocuments({ status: 'Cancelled' });

        // 3. Technical Workforce
        const verifiedTechs = await Technician.countDocuments({ status: 'active' }); // or approved
        const pendingTechs = await Technician.countDocuments({ status: 'pending' });
        const onlineTechs = await Technician.countDocuments({ isOnline: true });
        const deactivatedTechs = await Technician.countDocuments({ status: { $in: ['blocked', 'rejected', 'suspended'] } });

        // 4. Users
        const totalUsers = await User.countDocuments();
        const newUsers = await User.countDocuments({ createdAt: { $gte: startOfDay } });

        // 5. Recent Orders
        const recentOrders = await Booking.find()
            .sort({ createdAt: -1 })
            .limit(5)
            .populate('userId', 'name')
            .populate('technicianId', 'name');

        // 6. Active Orders (specifically for "Active Jobs" section)
        const activeOrders = await Booking.find({
            status: { $in: ['Accepted', 'On_Way', 'Arrived', 'In_Progress'] }
        })
            .sort({ createdAt: -1 })
            .limit(5)
            .populate('userId', 'name')
            .populate('technicianId', 'name');

        // 6. Revenue Trends (Today/Month)
        const revenueTodayAgg = await Booking.aggregate([
            { $match: { status: 'Completed', updatedAt: { $gte: startOfDay } } },
            { $group: { _id: null, total: { $sum: '$totalPrice' } } }
        ]);
        const revenueToday = revenueTodayAgg.length > 0 ? revenueTodayAgg[0].total : 0;

        const revenueMonthAgg = await Booking.aggregate([
            { $match: { status: 'Completed', updatedAt: { $gte: startOfMonth } } },
            { $group: { _id: null, total: { $sum: '$totalPrice' } } }
        ]);
        const revenueMonth = revenueMonthAgg.length > 0 ? revenueMonthAgg[0].total : 0;


        res.json({
            kpi: {
                totalOrders,
                completedOrders,
                activeTechs,
                totalRevenue,
                pendingPayouts,
                disputes: disputeStats.open + disputeStats.investigation
            },
            disputeStats,
            ordersOverview: {
                today: todayOrders,
                weekly: weeklyOrders,
                monthly: monthOrders,
                ongoing: ongoingOrders,
                scheduled: scheduledOrders,
                cancelled: cancelledOrders
            },
            revenueSummary: {
                gross: totalRevenue,
                net: pendingPayouts, // Payouts to techs
                commission: adminCommission,
                today: revenueToday,
                month: revenueMonth
            },
            techs: {
                verified: verifiedTechs,
                pending: pendingTechs,
                online: onlineTechs,
                deactivated: deactivatedTechs
            },
            users: {
                total: totalUsers,
                new: newUsers,
                returning: 'N/A' // placeholder
            },
            recentOrders,
            activeOrders
        });

    } catch (err) {
        console.error(err.message);
        res.status(500).send('Server Error');
    }
};
